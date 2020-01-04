#import "RCTVideoManager.h"
#import "RCTVideo.h"
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
#import <AVFoundation/AVFoundation.h>

@implementation RCTVideoManager

RCT_EXPORT_MODULE();

- (UIView *)view
{
  return [[RCTVideo alloc] initWithEventDispatcher:self.bridge.eventDispatcher];
}

- (dispatch_queue_t)methodQueue
{
    return self.bridge.uiManager.methodQueue;
}

RCT_EXPORT_VIEW_PROPERTY(src, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(maxBitRate, float);
RCT_EXPORT_VIEW_PROPERTY(resizeMode, NSString);
RCT_EXPORT_VIEW_PROPERTY(repeat, BOOL);
RCT_EXPORT_VIEW_PROPERTY(automaticallyWaitsToMinimizeStalling, BOOL);
RCT_EXPORT_VIEW_PROPERTY(allowsExternalPlayback, BOOL);
RCT_EXPORT_VIEW_PROPERTY(textTracks, NSArray);
RCT_EXPORT_VIEW_PROPERTY(selectedTextTrack, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(selectedAudioTrack, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(paused, BOOL);
RCT_EXPORT_VIEW_PROPERTY(muted, BOOL);
RCT_EXPORT_VIEW_PROPERTY(controls, BOOL);
RCT_EXPORT_VIEW_PROPERTY(volume, float);
RCT_EXPORT_VIEW_PROPERTY(playInBackground, BOOL);
RCT_EXPORT_VIEW_PROPERTY(playWhenInactive, BOOL);
RCT_EXPORT_VIEW_PROPERTY(pictureInPicture, BOOL);
RCT_EXPORT_VIEW_PROPERTY(ignoreSilentSwitch, NSString);
RCT_EXPORT_VIEW_PROPERTY(rate, float);
RCT_EXPORT_VIEW_PROPERTY(seek, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(currentTime, float);
RCT_EXPORT_VIEW_PROPERTY(fullscreen, BOOL);
RCT_EXPORT_VIEW_PROPERTY(fullscreenAutorotate, BOOL);
RCT_EXPORT_VIEW_PROPERTY(fullscreenOrientation, NSString);
RCT_EXPORT_VIEW_PROPERTY(filter, NSString);
RCT_EXPORT_VIEW_PROPERTY(filterEnabled, BOOL);
RCT_EXPORT_VIEW_PROPERTY(progressUpdateInterval, float);
RCT_EXPORT_VIEW_PROPERTY(restoreUserInterfaceForPIPStopCompletionHandler, BOOL);
/* Should support: onLoadStart, onLoad, and onError to stay consistent with Image */
RCT_EXPORT_VIEW_PROPERTY(onVideoLoadStart, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoLoad, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoBuffer, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoError, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoProgress, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBandwidthUpdate, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoSeek, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoEnd, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onTimedMetadata, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoAudioBecomingNoisy, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoFullscreenPlayerWillPresent, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoFullscreenPlayerDidPresent, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoFullscreenPlayerWillDismiss, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoFullscreenPlayerDidDismiss, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onReadyForDisplay, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlaybackStalled, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlaybackResume, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlaybackRateChange, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoExternalPlaybackChange, RCTDirectEventBlock);
RCT_REMAP_METHOD(save,
        options:(NSDictionary *)options
        reactTag:(nonnull NSNumber *)reactTag
        resolver:(RCTPromiseResolveBlock)resolve
        rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager prependUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RCTVideo *> *viewRegistry) {
        RCTVideo *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RCTVideo class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RCTVideo, got: %@", view);
        } else {
            [view save:options resolve:resolve reject:reject];
        }
    }];
}
RCT_EXPORT_VIEW_PROPERTY(onPictureInPictureStatusChanged, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onRestoreUserInterfaceForPictureInPictureStop, RCTDirectEventBlock);
RCT_EXPORT_METHOD(getDimensions:(NSString *)filepath resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    @try {
        filepath = [filepath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSURL *videoURL = [NSURL fileURLWithPath:filepath];

        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetTrack * videoAssetTrack = [asset tracksWithMediaType: AVMediaTypeVideo].firstObject;

        resolve(@{
            @"width": [NSNumber numberWithFloat: videoAssetTrack.naturalSize.width],
            @"height": [NSNumber numberWithFloat: videoAssetTrack.naturalSize.height],
        });
    } @catch(NSException *e) {
        reject(e.reason, nil, nil);
    }
}
RCT_EXPORT_METHOD(getFPS:(NSString *)filepath resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    @try {
        filepath = [filepath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSURL *videoURL = [NSURL fileURLWithPath:filepath];

        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetTrack * videoAssetTrack = [asset tracksWithMediaType: AVMediaTypeVideo].firstObject;

        resolve([NSNumber numberWithFloat: videoAssetTrack.nominalFrameRate]);
    } @catch(NSException *e) {
        reject(e.reason, nil, nil);
    }
}
RCT_EXPORT_METHOD(getDuration:(NSString *)filepath resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    @try {
        filepath = [filepath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSURL *videoURL = [NSURL fileURLWithPath:filepath];

        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetTrack * videoAssetTrack = [asset tracksWithMediaType: AVMediaTypeVideo].firstObject;

        resolve([NSNumber numberWithFloat: CMTimeGetSeconds(videoAssetTrack.timeRange.duration)]);
    } @catch(NSException *e) {
        reject(e.reason, nil, nil);
    }
}
RCT_EXPORT_METHOD(getFrame:(NSString *)filepath seconds:(float)seconds width:(int)width height:(int)height resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    @try {
        filepath = [filepath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSURL *videoURL = [NSURL fileURLWithPath:filepath];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform = YES;

        // **maximumSize** // 
        // This option allows us to specify the return image size
        generator.maximumSize = CGSizeMake(width, height);

        // **requestedTimeTolerance** //
        // These options at zero ensures the highest degree of accuracy in capturing the frame at the requested time.
        // without these options the frame returned for the requested time code could be off by greater than 1 second, or at 30ps, 30 frames
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        generator.requestedTimeToleranceAfter = kCMTimeZero;

        NSError *err = NULL;

        // We must generate a time code witht he Core Media class CMTimeMakeWithSeconds
        // The timescale derived from the asset.duration is equivelant to an FPS value in a different format.
        CMTime time = CMTimeMakeWithSeconds(seconds, asset.duration.timescale);
            
        CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage *thumbnail = [UIImage imageWithCGImage:imgRef];
        
        NSString* tempDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        
        NSData *data = UIImageJPEGRepresentation(thumbnail, 1.0);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *guid = [[NSUUID new] UUIDString];
        NSString *fullPath = [tempDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", guid] ];
        
        [fileManager createFileAtPath:fullPath contents:data attributes:nil];
        
        CGImageRelease(imgRef);

        resolve(fullPath);
    } @catch(NSException *e) {
        reject(e.reason, nil, nil);
    }
}

RCT_EXPORT_METHOD(getFrames:(NSString *)filepath resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    @try {
        filepath = [filepath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSURL *videoURL = [NSURL fileURLWithPath:filepath];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        AVAssetTrack * videoAssetTrack = [asset tracksWithMediaType: AVMediaTypeVideo].firstObject;

        generator.appliesPreferredTrackTransform = YES;
        generator.maximumSize = CGSizeMake(1280, 720);
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        generator.requestedTimeToleranceAfter = kCMTimeZero;

        
        float fps = videoAssetTrack.nominalFrameRate;
        int duration = CMTimeGetSeconds(videoAssetTrack.timeRange.duration);
        int totalFrameCount = round(duration * fps);
        
        __block NSMutableArray *images = [[NSMutableArray alloc]initWithCapacity:duration * fps];
        NSMutableArray* times = [[NSMutableArray alloc]initWithCapacity:duration * fps];
        
        for(Float64 i = 0; i < duration * fps; i++)
        {
            [times addObject: [NSValue valueWithCMTime:CMTimeMakeWithSeconds(i / fps, asset.duration.timescale)]];
        }

        NSLog(@"The content of times is%@", times);

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* tempDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
        __block unsigned int i = 0;
        [generator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
            i = i + 1;
            if (result == AVAssetImageGeneratorSucceeded) {
                UIImage* thumbnail = [[UIImage alloc] initWithCGImage:image scale:UIViewContentModeScaleAspectFit orientation:UIImageOrientationUp];
                
                NSData *data = UIImageJPEGRepresentation(thumbnail, 1.0);
                NSString *guid = [[NSUUID new] UUIDString];
                NSString *imagePath = [tempDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", guid] ];
                
                [fileManager createFileAtPath:imagePath contents:data attributes:nil];
                
                [images addObject:imagePath];
            }

            if (i == totalFrameCount) {
                resolve(images);
            }
        }];
        

    } @catch(NSException *e) {
        reject(e.reason, nil, nil);
    }
    
}

- (NSDictionary *)constantsToExport
{
  return @{
    @"ScaleNone": AVLayerVideoGravityResizeAspect,
    @"ScaleToFill": AVLayerVideoGravityResize,
    @"ScaleAspectFit": AVLayerVideoGravityResizeAspect,
    @"ScaleAspectFill": AVLayerVideoGravityResizeAspectFill
  };
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

@end
