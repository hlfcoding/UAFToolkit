//
//  UAFVideoResourceManager.m
//  UAFToolkit
//
//  Created by Peng Wang on 6/21/13.
//  Copyright (c) 2013 UseAllFive. See license.
//

#import "UAFVideoResourceManager.h"

static UAFVideoResourceManager *manager;

@implementation UAFVideoResourceManager

//-- UAFLocalStorage
@synthesize diskStoragePath, remotelyMirroredFiles, backgroundQueue;

- (id)init
{
  self = [super init];
  if (self) {
    self.remotelyMirroredFiles = [NSMutableDictionary new];
  }
  return self;
}

- (RKHTTPRequestOperation *)operationToDownloadVideoAsNeededForDataObject:(NSObject<UAFVideoableDataObject> *)object
{
  return [self operationToDownloadFileAsNeededForDataObject:object atURL:object.videoURL toURL:object.localVideoURL];
}

#pragma mark - UAFLocalStorage

- (RKHTTPRequestOperation *)operationToDownloadFileAsNeededForDataObject:(NSObject<UAFLocallyStoredDataObject> *)object atURL:(NSURL *)sourceURL toURL:(NSURL *)destinationURL;
{
  NSAssert(self.diskStoragePath, @"Disk storage path is required.");
  if (!self.diskStoragePath) {
    return nil;
  }
  NSError *error = nil;
  BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:
                  [[UAFVideoResourceManager sharedManager].diskStoragePath stringByAppendingPathComponent:object.relativeDiskStoragePath]
                                           withIntermediateDirectories:YES attributes:nil error:&error];
  if (!success) {
    ALog(@"Failed to create directory: %@", error);
  }
  void (^registerFile)(void) = ^{
    NSString *key = object.relativeDiskStoragePath;
    if (!self.remotelyMirroredFiles[key]) {
      self.remotelyMirroredFiles[key] = [NSMutableArray array];
    }
    [self.remotelyMirroredFiles[key] addObject:destinationURL];
  };
  if (!object.needsUpdate) {
    registerFile();
    DLog(@"GUARDED");
    return nil;
  }
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:sourceURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0f];
  RKHTTPRequestOperation *operation = [[RKHTTPRequestOperation alloc] initWithRequest:request];
  operation.outputStream = [NSOutputStream outputStreamWithURL:destinationURL append:NO];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    DLog(@"DOWNLOADED");
    registerFile();
    [object setValue:object.dateUpdated.copy forKey:@"previousDateUpdated"];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    ALog(@"Couldn't download file for %@ at %@: %@", object, sourceURL, error);
  }];
  return operation;
}

- (void)cleanDownloadedFilesForDataObjectsOfRelativePath:(NSString *)path
{
  NSAssert(self.backgroundQueue, @"Background dispatch-queue is required.");
  if (!self.backgroundQueue) {
    return;
  }
  NSArray *classFiles = self.remotelyMirroredFiles[path];
  if (!classFiles) {
    return DLog(@"GUARDED");
  }
  NSFileManager *fs = [NSFileManager defaultManager];
  NSString *fullPath = [self.diskStoragePath stringByAppendingPathComponent:path];
  NSDirectoryEnumerator *enumerator = [fs enumeratorAtPath:fullPath];
  //-- Do this async for performance.
  dispatch_async(self.backgroundQueue, ^{
    NSString *fileName = nil;
    while (fileName = [enumerator nextObject]) {
      NSString *filePath = [fullPath stringByAppendingPathComponent:fileName];
      NSURL *fileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
      NSError *error = nil;
      if ([classFiles indexOfObject:fileURL] == NSNotFound) {
        BOOL didRemove = [fs removeItemAtPath:filePath error:&error];
        if (didRemove) {
          DLog(@"DELETED FILE: %@", fileURL);
        } else {
          ALog(@"Failed to delete file: %@", error);
        }
      }
    }
  });
}

#pragma mark - Singleton

+ (void)initialize
{
  static BOOL initialized = NO;
  if (!initialized) {
    initialized = YES;
    manager = [UAFVideoResourceManager new];
  }
}

+ (UAFVideoResourceManager *)sharedManager
{
  return manager;
}

@end