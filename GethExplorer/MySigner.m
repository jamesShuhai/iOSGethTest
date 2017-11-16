//
//  MySigner.m
//  GethExplorer
//
//  Created by 书海 on 2017/11/7.
//  Copyright © 2017年 tangshuhai. All rights reserved.
//

#import "MySigner.h"

@interface MySigner()
@property (nonatomic, strong) GethKeyStore *keyStore;
@property (nonatomic, strong) NSString *passWd;
@property (nonatomic, strong) GethBigInt *chainId;
@property (nonatomic, strong) GethAccount *account;

@end

@implementation MySigner

-(GethTransaction *)sign:(GethAddress *)p0 p1:(GethTransaction *)p1 error:(NSError *__autoreleasing *)error{
    
    GethTransaction* tx = [self.keyStore signTxPassphrase:self.account passphrase:self.passWd tx:p1 chainID:self.chainId error:error];
    
    return tx;
}

-(instancetype)initWithKeyStore:(GethKeyStore *)keyStore Account:(GethAccount *)account PassWord:(NSString *)passWd andChainId:(GethBigInt *)chainId{
    
    self.keyStore = keyStore;
    self.account = account;
    self.passWd = passWd;
    self.chainId = chainId;
    return self;
}

@end
