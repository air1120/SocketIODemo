//
//  ViewController.m
//  SocketDemo
//
//  Created by Elaine on 17/2/28.
//  Copyright © 2017年 Rason. All rights reserved.
//

#import "ViewController.h"
#import "SocketDemo-Swift.h"
#define CURRENT_IP @"192.168.8.124"
#if TARGET_IPHONE_SIMULATOR
#define DEMO_HOST @"127.0.0.1"
#else
#define DEMO_HOST CURRENT_IP
#endif

@interface ViewController (){
    SocketIOClient *_socket;
}
@property (weak, nonatomic) IBOutlet UITextView *textViewMessage;

@property (weak, nonatomic) IBOutlet UITextField *textFieldIP;
@property (weak, nonatomic) IBOutlet UITextField *textFieldRoomName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldContent;
- (IBAction)createRoom:(id)sender;
- (IBAction)send:(id)sender;

- (IBAction)connectSocket:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)createRoom:(id)sender {
    
    [_socket emit:@"createRoom" with:@[self.textFieldRoomName.text]];
    
}

- (IBAction)send:(id)sender {
    [_socket emit:@"chatRoom" with:@[self.textFieldContent.text]];
}

- (IBAction)connectSocket:(id)sender {
    NSString *ip = [NSString stringWithFormat:@"%@:8080",DEMO_HOST];
    
    if ([self.textFieldIP.text length]!=0) {
        ip = self.textFieldIP.text;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"ws://%@",ip]];
    
    SocketIOClient *socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @YES, @"forcePolling": @YES}];
    _socket = socket;
    
    [socket connect];
    
    // 监听连接成功
    [socket on:@"connect" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ask) {
        
        NSLog(@"确定与服务器连接");
        [self addMessage:@"确定与服务器连接"];
        NSLog(@"%@ %@",data,ask);
        
    }];
    
    [socket on:@"chat" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ask) {
        NSLog(@"%@",data[0]);
        [self addMessage:data[0]];
    }];
    //注意这里不要设置多个on，会接收多次
    [_socket on:@"roomInfo" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ask) {
        [self addMessage:data[0]];
    }];
}
- (void)addMessage:(NSString *)message{
    self.textViewMessage.text = [NSString stringWithFormat:@"%@\n%@",self.textViewMessage.text,message];
    [self.textViewMessage scrollRectToVisible:CGRectMake(0, _textViewMessage.contentSize.height-15, _textViewMessage.contentSize.width, 10) animated:YES];
}
@end
