//
//  Configuration.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 24/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#ifndef iSofa_tv_Configuration_h
#define iSofa_tv_Configuration_h
typedef NS_ENUM(NSUInteger, RequestType)
{
    kRequestTypeFacebook,
    kRequestTypeYoutubeBest,
    kRequestTypeSearch,
    kRequestTypeChannel,
    kRequestTypeHistory
};
#define GRAPH_REQUEST @"me?fields=home.limit(500).fields(name,properties,created_time,source,link,from,message,picture)"
#define GOOGLE_API_KEY @"AIzaSyD9OGBEZ-sMiSJA_ae0plKT17P4sIVHn2I"
#endif
