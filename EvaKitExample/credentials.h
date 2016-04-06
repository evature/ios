//
//  credentials.h
//  EvaKit
//
//  Created by Iftah Haimovitch on 14/03/2016.
//  Copyright © 2016 Evature. All rights reserved.
//

#ifndef credentials_h
#define credentials_h

// register at http://www.evature.com/registration/form to get your credentials
// Place your API_KEY and SITE_CODE instead of the `nil`s below
#define API_KEY        nil
#define SITE_CODE      nil

// SCOPE is whatever your App supports,  eg. EVSearchContextTypeFlight, EVSearchContextTypeHotel, etc...
// if your app supports multiple scopes you can pass bit OR of the EVSearchContextType enums -  eg.   (EVSearchContextTypeFlight | EVSearchContextTypeHotel)
#define SCOPE       EVSearchContextTypeFlight

#endif /* credentials_h */
