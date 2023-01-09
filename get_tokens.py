
import os
import requests
import json


url = "https://cognito-idp.eu-central-1.amazonaws.com" 
proguider_user = os.environ['PROGUIDER_USER'] 
proguider_password = os.environ['PROGUIDER_PASSWORD']
proguider_client_id = os.environ['PROGUIDER_CLIENT_ID']
payload = {
   "AuthParameters" : {
      "USERNAME" : proguider_user,
      "PASSWORD" : proguider_password
   },
   "AuthFlow" : "USER_PASSWORD_AUTH",
   "ClientId" : proguider_client_id
}
headers = {
    'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth',
    'Content-Type': 'application/x-amz-json-1.1'
}
response = requests.request("POST", url, data=json.dumps(payload), headers=headers)
if response.status_code == 200:
    with open("tokens.json", "w") as f:
        f.write(response.text)
    print(response.text)
else:
    print(f"Failed to download tokens. Status code: {response.status_code}")
