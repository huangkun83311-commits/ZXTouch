//
//  ScriptListTableCell.m
//  zxtouch
//
//  Created by Jason on 2020/12/14.
//

#import "ScriptListTableCell.h"
#import "Socket.h"
#import "Util.h"

BOOL connected = NO;

@implementation ScriptListTableCell
{
    NSString* filePath;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)playButtonClick:(id)sender {
    connected = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        Socket *springBoardSocket = [[Socket alloc] init];
        int ret = [springBoardSocket connect:@"127.0.0.1" byPort:6000];
        if (ret != 0) {
            return;
        }
        
        [springBoardSocket send:[NSString stringWithFormat:@"19%@", self->filePath]];
        NSString *result = [springBoardSocket recv:1024];
        if (result.length == 0 || [result characterAtIndex:0] != '0') {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Util showAlertBoxWithOneOption:self->_parentViewController title:@"Error" message:[NSString stringWithFormat:@"Cannot play script. Error: %@", result] buttonString:@"OK"];
            });
        }
        [springBoardSocket close];
        connected = NO;
    });
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setTitle:(NSString*)title{
    _scriptTitle.text = title;
}

- (void) hideButton{
    [_playButton setHidden:YES];
}

- (void) showButton{
    [_playButton setHidden:NO];
}

- (void) setPropertyWithPath:(NSString*)path{
    filePath = path;
    
    BOOL isDir = NO;
    _scriptTitle.text = [path lastPathComponent];
    [self showButton];

    if ([[path pathExtension] isEqualToString:@"bdl"]) // is script. can play
    {
        // Now the image will have been loaded and decoded and is ready to rock for the main thread
        [[self imageView] setImage:[UIImage imageNamed:@"script-icon"]];
        
        return;
    }
    
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    [self hideButton];

    if (!isDir)
    {
        [[self imageView] setImage:[UIImage imageNamed:@"normal-file-icon"]];
    }
    else
    {
        [[self imageView] setImage:[UIImage imageNamed:@"folder-icon"]];
    }
}

@end
