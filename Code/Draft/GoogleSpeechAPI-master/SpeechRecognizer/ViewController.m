#import "ViewController.h"
#import "SoundRecoder.h"
#import "Recorder.h"

#define GOOGLE_API_URL @"https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=%@&maxresults=%d&pfilter=0"

@interface ViewController () <SoundRecoderDelegate>{
	IBOutlet UILabel *_resulfField;
	IBOutlet UILabel *_confField;
	IBOutlet UISegmentedControl *_langSelection;
	Recorder *_recorder;
}
@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
	_recorder = [[Recorder alloc] init];
	[_resulfField setText:@""];
	[_confField setText:@""];
}

- (void)dealloc{
    [_recorder release];
    [super dealloc];
}

-(IBAction)recoderButtonDidPress:(id)sender{
	NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
	NSString *savePath = [documentDir stringByAppendingPathComponent:@"test.flac"];
	[_recorder startRecording];
}

-(IBAction)recoderButtonDidRelease:(id)sender{
	[_recorder stopRecording];
}

-(void)soundRecoderDidFinishRecording:(SoundRecoder *)recoder{
	recoder.delegate = nil;
	[self performSelectorInBackground:@selector(makeRecognitionRequest:) withObject:recoder.savedPath];
}

-(void)recognitionDidFinish:(NSArray*)results{
	if( !results || [results count]==0 ){
		[_resulfField setText:@"No matching result"];
		[_confField setText:@""];
		return;
	}
	[_resulfField setText:[NSString stringWithFormat:@"%@",results[0][0]]];
	[_confField setText:[NSString stringWithFormat:@"%.1f%%",[results[0][1] floatValue]*100.f]];
}

-(void)makeRecognitionRequest:(NSString*)soundPath{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSData *soundData = [NSData dataWithContentsOfFile:soundPath];
	if( !soundData ){
		[pool release];
		return;
	}
	
	NSArray *langList = @[@"ja-JP",@"en-US"];
	NSString *lang = langList[_langSelection.selectedSegmentIndex];
	NSString *url = [NSString stringWithFormat:GOOGLE_API_URL,lang,3];
	NSLog(@"URL: %@",url);
	
	NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	[rq setHTTPMethod:@"POST"];
	[rq addValue:@"audio/x-flac; rate=44100" forHTTPHeaderField:@"Content-Type"];
	[rq setHTTPBody:soundData];
	
	NSHTTPURLResponse* res = nil;
	NSError *error = NULL;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:rq returningResponse:&res error:&error];
	NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	if ( !([res statusCode] >= 200 && [res statusCode] < 300) ) {
		[pool release];
		return;
	}
	if( !result || [result length] <= 0 ){
		[pool release];
		return;
	}
	NSLog(@"%@",result);
	
	NSString *regexp_str = @"\\{\"utterance\":\"([^\"]*?)\",\"confidence\":([\\d\\.]+?)\\}";
	NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regexp_str options:0 error:nil];
	NSRange range;
	range.location = 0;
	range.length = [result length];
	NSArray *matches = [regexp matchesInString:result options:0 range:NSMakeRange(0,[result length])];
	
	NSMutableArray *recognitionResults = [NSMutableArray array];
	for (NSTextCheckingResult *item in matches) {
		NSString *word = [result substringWithRange:[item rangeAtIndex:1]];
		NSNumber *conf = [NSNumber numberWithFloat:[[result substringWithRange:[item rangeAtIndex:2]] floatValue]];
		[recognitionResults addObject:@[word,conf]];
	}
	[self performSelectorOnMainThread:@selector(recognitionDidFinish:) withObject:recognitionResults waitUntilDone:NO];
	
	[pool release];
}

@end
