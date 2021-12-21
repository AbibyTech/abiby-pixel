___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Abiby - Pixel",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "partnerId",
    "displayName": "Partner ID",
    "simpleValueType": true,
    "alwaysInSummary": true
  },
  {
    "type": "TEXT",
    "name": "propertyId",
    "displayName": "Property ID",
    "simpleValueType": true,
    "alwaysInSummary": true
  },
  {
    "type": "SELECT",
    "name": "eventName",
    "displayName": "Event name",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "PageView",
        "displayValue": "PageView"
      },
      {
        "value": "AddToCart",
        "displayValue": "AddToCart"
      },
      {
        "value": "Checkout",
        "displayValue": "Checkout"
      }
    ],
    "simpleValueType": true,
    "alwaysInSummary": true,
    "defaultValue": "PageView"
  },
  {
    "type": "TEXT",
    "name": "checkoutValue",
    "displayName": "Checkout Value",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "eventName",
        "paramValue": "Checkout",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "cartValue",
    "displayName": "Cart Total",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "eventName",
        "paramValue": "AddToCart",
        "type": "EQUALS"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Enter your template code here.
const log = require('logToConsole');
const getTimestamp = require('getTimestamp');
const Math = require('Math');
const generateRandom = require('generateRandom');
const getCookieValues = require('getCookieValues');
const toBase64 = require('toBase64');
const setCookie = require('setCookie');
const getQueryParameters = require('getQueryParameters');
const JSON = require('JSON');
const encodeUriComponent = require('encodeUriComponent');
const getUrl = require('getUrl');
const readTitle = require('readTitle');
const sendPixel = require('sendPixel');

log('data =', data);

const domain = 'ext-insights.abiby.net';
const abibyTrackingBaseUrl = 'https://insights.abiby.net/api/collect?';
const prefix = 'BI2';
const timestamp = getTimestamp();
const randomUID = Math.round(2147483647 * generateRandom(0,100));
const fullHost = getUrl(); // location field
const hostName = getUrl('host'); //NOTE: used for product category, affiliation
const pathName = encodeUriComponent(getUrl('path'));
const pageTitle = readTitle();

// Create Abiby Tracking UID
const uidCookieName = '__abb__uid';
const utmCookieName = '__abb__bic';

// Create UID Tracking cookie if dosen't exist
var uid;
let uidCookie = getCookieValues(uidCookieName);

if (getCookieValues(uidCookieName).length === 0) {
  uid = prefix + '.' + randomUID + '.' + timestamp;
  setCookie(uidCookieName, uid, {
    domain: domain,
    path: '/',
    'max-age': 2*365*24*60 
  });
} else {
  uid = getCookieValues(uidCookieName)[0];
}

log('uid =', uid);

var utm_campaign = getQueryParameters('utm_campaign');
var utm_content = getQueryParameters('utm_content');
var utm_medium = getQueryParameters('utm_medium');
var utm_source = getQueryParameters('utm_source');
var utm_term = getQueryParameters('utm_term');

var utm = {
  'utm_campaign': utm_campaign,
  'utm_content': utm_content,
  'utm_medium': utm_medium,
  'utm_source': utm_source,
  'utm_term': utm_term,
};

log('utm_json =', JSON.stringify(utm));
var utmHash = toBase64(JSON.stringify(utm));


log('utm =', utm);
log('utm_hash =', utmHash);

if (utmHash !== 'e30=')
{
	if (getCookieValues(utmCookieName).length !== 0)
	{
	    if (utmHash != getCookieValues(utmCookieName))
	    {
	        setCookie(utmCookieName, utmHash, {
	          domain: domain,
	          path: '/',
	          'max-age': 30 
	        });
	    } else {
		   setCookie(utmCookieName, getCookieValues(utmCookieName), {
		      domain: domain,
		      path: '/',
		      'max-age': 30 
		    });
	    }
	} else {
	    setCookie(utmCookieName, utmHash, {
          domain: domain,
          path: '/',
          'max-age': 30 
        });
    }
}


var queryBuilder = function(obj, prefix) {
  var str = [], p;
  for (p in obj) {
    if (obj.hasOwnProperty(p)) {
      var k = prefix ? prefix + "[" + p + "]" : p,
          v = obj[p];
          str.push((v !== null && typeof v === "object") ?
          queryBuilder(v, k) :
          encodeUriComponent(k) + "=" + encodeUriComponent(v));
    }
  }
  return str.join("&");
};

const abibyUid = getQueryParameters('uid');
log('abibyUid', abibyUid);
// Abiby Tracking Payload
var payload = {
  'e': data.eventName,
  'uid': uid,
  'aid': abibyUid,
  'pid': data.partnerId,
  'cs': utm_source,
  'cm': utm_medium,
  'cn': utm_campaign,
  'cc': utm_content,
  'ck': utm_term,
  'dp': pathName,
  'dh': hostName,
  'dt': pageTitle
};

if (getCookieValues(utmCookieName).length !== 0)
{
  payload.uh = getCookieValues(utmCookieName)[0];
}

log(payload);
log(queryBuilder(payload));

var abibyPixelRequest =  abibyTrackingBaseUrl + queryBuilder(payload);
log('abibyPixelRequest =', abibyPixelRequest );
sendPixel(abibyPixelRequest);

// GA Tracking behind measurement protocol
const uaCode = 'UA-' + data.propertyId; //TODO
const clientId = timestamp +' '+ generateRandom(1,999); //TODO

let gaPayload = {
  'z': timestamp,  // Event timestamp
  'v': 1, // Version
  'tid': uaCode, // Tracking ID / Property ID.
  'cid': clientId, // Anonymous Client ID.
  't': 'pageview', // Pageview hit type.
  'dp': pathName, // Page
  'dh': hostName, // Document hostname.
  'dt': pageTitle
};

if(data.eventName == 'Checkout')
{
  gaPayload.t = 'event';
  gaPayload.ec = 'ecommerce';       // Event Category. Required.
  gaPayload.ea = 'checkout';         // Event Action. Required.
  gaPayload.el = '';      // Event label.
  gaPayload.ev = data.checkoutValue;          // Event value.
}

if(data.eventName == 'AddToCart')
{
  gaPayload.t = 'event';
  gaPayload.ec = 'ecommerce';       // Event Category. Required.
  gaPayload.ea = 'addToCart';         // Event Action. Required.
  gaPayload.el = '';      // Event label.
  gaPayload.ev = data.cartValue;          // Event value.
}

log('gaPayload =', gaPayload);
let gaRequest = 'https://www.google-analytics.com/collect?' + queryBuilder(gaPayload);

log('gaRequest =', gaRequest);

sendPixel(gaRequest);


// Call data.gtmOnSuccess when the tag is finished.
data.gtmOnSuccess();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "__abb__uid"
              },
              {
                "type": 1,
                "string": "__abb__bic"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "set_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedCookies",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "__abb__uid"
                  },
                  {
                    "type": 1,
                    "string": "abiby.net"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "__abb__bic"
                  },
                  {
                    "type": 1,
                    "string": "abiby.net"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_url",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queriesAllowed",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_pixel",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://www.google-analytics.com/collect*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_title",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 21/12/2021, 10:27:33


