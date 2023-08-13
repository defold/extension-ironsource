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

def remove_spaces_and_newlines(text):
    cleaned_text = text.strip()
    return cleaned_text

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

# Example usage
url = "https://developers.is.com/ironsource-mobile/ios/mediation-networks-ios/"
var_name = "sdk_data"
site_values = parse_js_table(url, var_name)
# print(site_values)
mapping = {
        'AdColony': 'adcolony',
        'AppLovin': 'applovin',
        'APS': 'aps',
        'BidMachine': 'bidmachine',
        'Chartboost': 'charboost',
        'CSJ': 'csj',
        'Digital Turbine': 'fyber',
        'Facebook': 'facebook',
        'Google': 'admob',
        'HyprMX': 'hyprmx',
        'InMobi': 'inmobi',
        'Liftoff Monetize': 'liftoff',
        'Maio': 'maio',
        'Mintegral': 'mintegral',
        'myTarget': 'mytarget',
        'Pangle': 'pangle',
        'Smaato': 'smaato',
        'SuperAwesome': 'superawesome',
        'Tapjoy': 'tapjoy',
        'Tencent': 'tencent',
        'UnityAds': 'unityads',
    }

result = ""
lines = result.splitlines()
result = '\n'.join(lines[:-1])
result += """

"""
repositories = """platform :ios, '10.0'
"""
repositories += site_values['sdk_cocoapods']

del site_values['sdk_maven']
del site_values['sdk_cocoapods']
for key, value in site_values.items():
    if mapping.get(key) is None:
        exit(f"Adapter `{key}` was added. Please change `mappings` in this script and add adapter to `game.project` and `ext.properties`")

for key, value in mapping.items():
    if site_values.get(key) is None:
        exit(f"Adapter `{key}` was removed. Please change `mappings` in this script and remove adapter from `game.project` and `ext.properties`")

for key, value in mapping.items():
    result += f"{{{{#iron_source.{value}_ios}}}}\n"
    result += remove_spaces_and_newlines(site_values[key]['code'])
    result += f"\n{{{{/iron_source.{value}_ios}}}}\n\n"

result = repositories + result

with open("../extension-ironsource/manifests/ios/Podfile", "w") as file:
    file.write(result)
