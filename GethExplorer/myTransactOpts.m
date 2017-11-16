//
//  myTransactOpts.m
//  GethExplorer
//
//  Created by 书海 on 2017/11/7.
//  Copyright © 2017年 tangshuhai. All rights reserved.
//

#import "myTransactOpts.h"
@interface myTransactOpts()

@property (nonatomic, strong) GethContext *context;
@property (nonatomic, strong) GethAddress *from;
@property (nonatomic,assign) int64_t gasLimit;
@property (nonatomic, strong) GethBigInt *gasPrice;
@property (nonatomic, strong) GethSigner *signer;
@property (nonatomic, assign) int64_t nonce;

@end

@implementation myTransactOpts

-(instancetype)initwithContext:(GethContext *)context from:(GethAddress *)from gasLimit:(int64_t)gasLimit gasPrice:(GethBigInt *)gasPrice signer:(GethSigner *)signer nonce:(int64_t)nonce{
    
    self.context = context;
    self.from = from;
    self.gasLimit = gasLimit;
    self.gasPrice = gasPrice;
    self.signer = signer;
    self.nonce = nonce;
//    [self setContext:context];
//    [self setFrom:from];
//    [self setGasLimit:gasLimit];
//    [self setGasPrice:gasPrice];
//    [self setSigner:signer];
//    [self setNonce:nonce];
    
    return self;
}
- (GethAddress*)getFrom{
    return _from;
}
- (int64_t)getGasLimit{
    return _gasLimit;
}
- (GethBigInt*)getGasPrice{
    return _gasPrice;
}
- (int64_t)getNonce{
    return _nonce;
}
-(GethContext*)getContext{
    return _context;
}
-(GethSigner *)getSigner{
    return _signer;
}
@end
