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
    # Split the text into a list of words
    words = text.split()

    # Find the index of the var_name string in the list of words
    try:
        index = words.index(var_name)
    except ValueError:
        print(f"The '{var_name}' string was not found in the text.")
        return ""

    # Extract all the words after the var_name string
    result = " ".join(words[index+1:])

    return result

def parse_js_table(url, var_name):
    # Send a GET request to the URL
    response = requests.get(url)

    # Parse the HTML content of the response using BeautifulSoup
    soup = BeautifulSoup(response.content, 'html.parser')

    # Search for the specified JavaScript variable in the HTML content
    script = soup.find('script', string=lambda t: t and var_name in t)
    if script:
        # Extract the JSON data from the JavaScript variable
        text = extract_text_after(script.text, var_name)
        start = text.find('{')
        end = text.rfind('}') + 1
        json_data = text[start:end]

        # Parse the JSON data as a Python table
        table = json.loads(json_data)

        return table
    else:
        print(f"Did not find '{var_name}' in the URL '{url}'")

def remove_china_market(text):
    if "//china market only" in text:
        text = text.split("//china market only", 1)[0]
    return text

# Example usage
url = "https://developers.is.com/ironsource-mobile/android/mediation-networks-android"
var_name = "sdk_data"
site_values = parse_js_table(url, var_name)
mapping = {
        # 'AdColony': 'adcolony',
        'AppLovin': 'applovin',
        'APS': 'aps',
        'BidMachine': 'bidmachine',
        'Chartboost': 'charboost',
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
        'UnityAds': 'unityads',
        'Yandex Ads': 'yandex_ads'
    }

result = site_values['sdk_maven']
lines = result.splitlines()
result = '\n'.join(lines[:-1])
result += """

// Remove for AMAZON:
// --- NOT AMAZON START ---
    implementation fileTree(dir: 'libs', include: ['*.jar']) 
    implementation 'com.google.android.gms:play-services-appset:16.0.0' 
    implementation 'com.google.android.gms:play-services-ads-identifier:18.0.1' 
    implementation 'com.google.android.gms:play-services-basement:18.1.0' 
// --- NOT AMAZON END ---

"""
repositories = """

repositories {
    mavenCentral()
    maven {url 'https://android-sdk.is.com/'}

"""

del site_values['sdk_maven']
del site_values['sdk_cocoapods']
for key, value in site_values.items():
    if mapping.get(key) is None:
        exit(f"Adapter `{key}` was added. Please change `mappings` in this script and add adapter to `game.project` and `ext.properties`")

for key, value in mapping.items():
    if site_values.get(key) is None:
        exit(f"Adapter `{key}` was removed. Please change `mappings` in this script and remove adapter from `game.project` and `ext.properties`")

for key, value in mapping.items():
    result += f"{{{{#iron_source.{value}_android}}}}\n"
    result += remove_china_market(site_values[key]['dependency'])
    result += f"\n{{{{/iron_source.{value}_android}}}}\n\n"
    if len(site_values[key]['maven']) > 0 and not site_values[key]['maven'].isspace():
        repositories += f"    {{{{#iron_source.{value}_android}}}}\n"
        repositories += "    " + site_values[key]['maven']
        repositories += f"\n    {{{{/iron_source.{value}_android}}}}\n\n"

result += "}"
repositories += "}\n"
result = repositories + result

with open("../extension-ironsource/manifests/android/build.gradle", "w") as file:
    file.write(result)
