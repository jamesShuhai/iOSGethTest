//
//  myTransactOpts.h
//  GethExplorer
//
//  Created by 书海 on 2017/11/7.
//  Copyright © 2017年 tangshuhai. All rights reserved.
//

#import <Geth/Geth.h>

@interface myTransactOpts : GethTransactOpts

-(instancetype)initwithContext:(GethContext *)context from:(GethAddress *)from gasLimit:(int64_t)gasLimit gasPrice:(GethBigInt *)gasPrice signer:(GethSigner *)signer nonce:(int64_t)nonce;

@end
