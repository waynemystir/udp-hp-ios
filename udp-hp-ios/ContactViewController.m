//
//  ContactViewController.m
//  udp-hp-ios
//
//  Created by WAYNE SMALL on 3/17/17.
//  Copyright © 2017 Waynemystir. All rights reserved.
//

#import "ContactViewController.h"
#import "udp_client.h"
#import "VideoCallViewController.h"
#import "Shared.h"

@interface ContactViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITextView *chatHistoryTextView;

@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *roomId;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomPadding;

@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [self.contact username];
    UIBarButtonItem *rb = [[UIBarButtonItem alloc] initWithTitle:@"V" style:UIBarButtonItemStylePlain target:self action:@selector(startVideoCall:)];
    self.navigationItem.rightBarButtonItem = rb;
    self.messageTextField.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    NSNotificationCenter *ncd = [NSNotificationCenter defaultCenter];
    [ncd addObserver:self selector:@selector(handleKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
    [ncd addObserver:self selector:@selector(handleKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
    [ncd addObserver:self selector:@selector(updateChatHistoryTextView) name:kNotificationChatMsgRecd object:nil];
    [self updateChatHistoryTextView];
}

- (void)updateChatHistoryTextView {
    contact_t *the_contact = self.contact.theContact;
    chat_history_list_t *chl = the_contact->chat_history;
    if (chl == NULL) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chatHistoryTextView.text = [self chat_history_to_ns_string:chl];
        NSRange bottom = NSMakeRange(self.chatHistoryTextView.text.length - 1, 1);
        [self.chatHistoryTextView scrollRangeToVisible:bottom];
    });
}

- (NSString *)chat_history_to_ns_string:(chat_history_list_t *)chl {
    if (chl == NULL || chl->head == NULL || chl->count == 0) return nil;

    NSString *rs = @"";
    chat_history_node_t *chn = chl->head;
    while (chn) {
        NSString *un = [NSString stringWithUTF8String:chn->username];
        NSString *msg = [NSString stringWithUTF8String:chn->msg];
        NSString *nl = [rs isEqualToString:@""] ? @"" : @"\n";
        NSString *appStr = [rs stringByAppendingFormat:@"%@%@: %@", nl, un, msg];
        rs = appStr;
        chn = chn->next;
    }
    
    return rs;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleKeyboardNotification:(NSNotification*)notification {
    NSDictionary *info = notification.userInfo;
    
    NSValue* durationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = 0;
    [durationValue getValue:&animationDuration];
    
    NSValue* kbfValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame;
    [kbfValue getValue:&keyboardEndFrame];
    
    CGRect convertedKeyboardEndFrame = [self.view convertRect:keyboardEndFrame fromView:self.view.window];
    self.constraintBottomPadding.constant = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame);
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        NSRange bottom = NSMakeRange(self.chatHistoryTextView.text.length - 1, 1);
        [self.chatHistoryTextView scrollRangeToVisible:bottom];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *msgText = textField.text;
    send_message_to_contact(self.contact.theContact, (char*)[msgText UTF8String]);
    add_self_chat_history((char*)[self.contact.username UTF8String], (char*)[msgText UTF8String]);
    [self updateChatHistoryTextView];
    textField.text = @"";
    return YES;
}

- (IBAction)startVideoCall:(id)sender {
    char *video_call_url = NULL;
    char *room_id = NULL;
    start_video_with_contact(self.contact.theContact, &video_call_url, &room_id);
    if (video_call_url && room_id) {
        self.videoUrl = [NSString stringWithUTF8String:video_call_url];
        self.roomId = [NSString stringWithUTF8String:room_id];
        [self performSegueWithIdentifier:@"sbidSegueContactToVideoVC" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"sbidSegueContactToVideoVC"]) {
        VideoCallViewController *vcvc = segue.destinationViewController;
        vcvc.viewControllerToPopTo = self;
        vcvc.serverHostUrl = self.videoUrl;
        vcvc.roomName = self.roomId;
    }
}


@end
