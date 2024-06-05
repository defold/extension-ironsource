#!/usr/bin/env python3

import json

try:
    import requests
except ImportError:
    print("Requests not found. Installing...")
    try:
        import pip
        pip.main(['install', 'requests'])
        import requests
    except:
        print("Failed to install Requests. Please install it manually.")
        exit()
try:
    from bs4 import BeautifulSoup
except ImportError:
    print("BeautifulSoup not found. Installing...")
    try:
        import pip
        pip.main(['install', 'beautifulsoup4'])
        from bs4 import BeautifulSoup
    except:
        print("Failed to install BeautifulSoup. Please install it manually.")
        exit()

def extract_text_after(text, var_name):
    words = text.split()
    try:
        index = words.index(var_name)
    except ValueError:
        print(f"The '{var_name}' string was not found in the text.")
        return ""
    result = " ".join(words[index+1:])
    return result

def remove_spaces_and_newlines(text):
    cleaned_text = text.strip()
    return cleaned_text

def parse_js_table(url, var_name):
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    script = soup.find('script', string=lambda t: t and var_name in t)
    if script:
        text = extract_text_after(script.text, var_name)
        start = text.find('{')
        end = text.rfind('}') + 1
        json_data = text[start:end]
        table = json.loads(json_data)
        return table
    else:
        print(f"Did not find '{var_name}' in the URL '{url}'")
        return {}

url = "https://developers.is.com/ironsource-mobile/ios/mediation-networks-ios/"
var_name = "sdk_data"
site_values = parse_js_table(url, var_name)

mapping = {
    'AppLovin': 'applovin',
    'APS': 'aps',
    'BidMachine': 'bidmachine',
    'Chartboost': 'charboost',
    'CSJ': 'csj',
    'DT Exchange': 'dt_exchange',
    'Facebook': 'facebook',
    'Google': 'admob',
    'HyprMX': 'hyprmx',
    'InMobi': 'inmobi',
    'Liftoff Monetize': 'liftoff',
    'Maio': 'maio',
    'Mintegral': 'mintegral',
    'Moloco': 'moloco',
    'myTarget': 'mytarget',
    'Pangle': 'pangle',
    'Smaato': 'smaato',
    'SuperAwesome': 'superawesome',
    'Tencent': 'tencent',
    'UnityAds': 'unityads',
    'Yandex Ads': 'yandex_ads'
}

result = ""
lines = result.splitlines()
result = '\n'.join(lines[:-1])
result += "\n\n"

repositories = """platform :ios, '13.0'\n"""
repositories += site_values['sdk_cocoapods']

del site_values['sdk_maven']
del site_values['sdk_cocoapods']
stripped_site_values = {key.strip(): value for key, value in site_values.items()}
for key, value in stripped_site_values.items():
    if mapping.get(key) is None:
        exit(f"Adapter `{key}` was added. Please change `mappings` in this script and add adapter to `game.project` and `ext.properties`")

for key, value in mapping.items():
    if stripped_site_values.get(key) is None:
        exit(f"Adapter `{key}` was removed. Please change `mappings` in this script and remove adapter from `game.project` and `ext.properties`")

for key, value in mapping.items():
    result += f"{{{{#iron_source.{value}_ios}}}}\n"
    result += remove_spaces_and_newlines(stripped_site_values[key]['code'])
    result += f"\n{{{{/iron_source.{value}_ios}}}}\n\n"

result = repositories + result

with open("../extension-ironsource/manifests/ios/Podfile", "w") as file:
    file.write(result)

# Parsing PLIST_NETWORK_IDS and generating Info.plist
skadnetwork_url = "https://developers.is.com/ironsource-mobile/flutter/managing-skadnetwork-ids/"
var_name = "PLIST_NETWORK_IDS"
skadnetwork_data = parse_js_table(skadnetwork_url, var_name)

if skadnetwork_data:
    ironSource_ids = set(skadnetwork_data.get("ironSource", [])[1])
    cleaned_networks = {}

    for network, ids in skadnetwork_data.items():
        if network != "ironSource":
            cleaned_ids = [id_ for id_ in ids[1] if id_ not in ironSource_ids]
            if cleaned_ids:
                cleaned_networks[network] = cleaned_ids

    skadnetwork_ids = list(ironSource_ids)  # Start with ironSource IDs
else:
    skadnetwork_ids = []

plist_template = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd" [ <!ATTLIST key merge (keep) #IMPLIED> ]>
<plist version="1.0">
    <dict>
        <key merge='keep'>SKAdNetworkItems</key>
        <array>
//here
        </array>

        <key>NSAppTransportSecurity</key>
        <dict>
            <key>NSAllowsArbitraryLoads</key>
            <true/>
{{#iron_source.ios_enable_ats}}
            <key>NSAllowsLocalNetworking</key>  
            <true/>
            <key>NSAllowsArbitraryLoadsInWebContent</key>
            <true/>
            <key>NSAllowsArbitraryLoadsForMedia</key>
            <true/>
{{/iron_source.ios_enable_ats}}
{{#iron_source.tapjoy_ios}}
            <key>NSExceptionDomains</key>
            <dict>
               <key>localhost</key>
               <dict>           
                   <key>NSExceptionAllowsInsecureHTTPLoads</key>
                   <true/>
               </dict>
            </dict>
{{/iron_source.tapjoy_ios}}
        </dict>

{{#iron_source.admob_ios}}
        <key>GADApplicationIdentifier</key>
        <string>{{iron_source.admob_ios_appid}}</string>
{{/iron_source.admob_ios}}

        <key>NSUserTrackingUsageDescription</key>
        <string>{{iron_source.ios_tracking_usage_description}}</string>

{{#iron_source.ios_use_skan}}
        <key>NSAdvertisingAttributionReportEndpoint</key>
        <string>https://postbacks-is.com</string>
{{/iron_source.ios_use_skan}}

{{#iron_source.hyprmx_ios}}
        <key>NSCameraUsageDescription</key>
            <string>{{project.title}} requests write access to the Camera</string>
        <key>NSCalendarsUsageDescription</key>
            <string>{{project.title}} requests access to the Calendar</string>
        <key>NSPhotoLibraryUsageDescription</key>
            <string>{{project.title}} requests access to the Photo Library</string>
        <key>NSPhotoLibraryAddUsageDescription</key>
            <string>{{project.title}} requests write access to the Photo Library</string> 
{{/iron_source.hyprmx_ios}}

    </dict>
</plist>
"""

# Insert the SKAdNetwork IDs into the plist template
skadnetwork_items = "\n".join([f"            <dict><key>SKAdNetworkIdentifier</key><string>{item}</string></dict>" for item in skadnetwork_ids])

# Add blocks for each network
for network, ids in cleaned_networks.items():
    if network in mapping:
        network_key = mapping[network]
        skadnetwork_items += f"\n{{{{#iron_source.{network_key}_ios}}}}\n"
        skadnetwork_items += "\n".join([f"            <dict><key>SKAdNetworkIdentifier</key><string>{item}</string></dict>" for item in ids])
        skadnetwork_items += f"\n{{{{/iron_source.{network_key}_ios}}}}\n"

plist_content = plist_template.replace("//here", skadnetwork_items)

with open("../extension-ironsource/manifests/ios/Info.plist", "w") as file:
    file.write(plist_content)
