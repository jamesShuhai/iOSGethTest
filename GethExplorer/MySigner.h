//
//  MySigner.h
//  GethExplorer
//
//  Created by 书海 on 2017/11/7.
//  Copyright © 2017年 tangshuhai. All rights reserved.
//

#import <Geth/Geth.h>

@interface MySigner : GethSigner

-(instancetype)initWithKeyStore:(GethKeyStore *)keyStore Account:(GethAccount *)account PassWord:(NSString *)passWd andChainId:(GethBigInt *)chainId;

@end
