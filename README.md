# RestForBackPain

RestForBackPain(R4BP) is a cross-platform(Desktop, web and mobile) general admin application for manage backend data using RESTful APIs.

## Notice

This project is still in very early preview. It's only tested on MacOS and might be unstable.

## Getting Started
1. [Install Flutter](https://flutter.dev/docs/get-started/install)
2. [Set up flutter for desktop application](https://flutter.dev/desktop#set-up)
3. Get plugins: `fluter pub get`
4. Run project: `flutter run`

or</br>

&emsp;&emsp;Download [release buid](https://github.com/HedgeHao/restforbackpain/releases)

## Usage

### Generate config file
R4BP use a config file to get the structure for the backend service. First we have to generate the config file. Go to settings and enter the database credentials then click "connect". The config file will generate by itself. Click "save" button to save it to file.

![image](https://raw.githubusercontent.com/HedgeHao/restforbackpain/master/images/screenshot1.png)

### Structure backend service
After having the config file. Click "refresh" button on the bottom left. You'll see the models got updated. Click any model name you want it will query all the records in this model. Click the row wiil show the details of that record. You can modify and save the changes.

![image](https://raw.githubusercontent.com/HedgeHao/restforbackpain/master/images/screenshot2.png)

![image](https://raw.githubusercontent.com/HedgeHao/restforbackpain/master/images/screenshot3.png)


### Model Format
R4BP will connect to the database and get every table's structures including name, data type, nullable. Parse it the a json file. You can modify this config file manually.
```
{
    ...
    "models":{
        "<MODEL_NAME>":{
            "struct":[
                {
                    "name": "<FIELD_NAME>",
                    "type": "<DATA_TYPE>",
                    "default": "<DEFAULT_VALUE>",
                    "null": <NULLABLE>
                }
            ]
        }
    }
}
```
If we have a model(table) named 'user' and it has one field(column) named 'username'. The config file will look something like this:
```
{
    ...
    "models":{
        "user":{
            "struct":[
                {
                    "name": "username",
                    "type": "string",
                    "default": "",
                    "null": false,
                }
            ]
        }
    }
}    
```

** Each model must have a field called 'id' with type 'integer' as a indicator of each record.

** Data type currently support 'string', 'integer', 'float', 'boolean', 'date', 'datetime', 'html'

### API Format
R4BP use HTTP request with specific URL pattern to interact to backend service. Below is the API format in config file. </br>

There are five actions R4BP can do for each models. You have to implement these functions in your backend service and expose it as a web service then provide the URL information for R4BP to access.
```
{
    "host": "<HOST>"
    ...
    "models": {
        "<MODEL_NAME>": {
            ...
            "endpoints": {
                "name": "<BASE NAME>",
                "actions":{
                    "create": ["<HTTP_METHOD>", "<URI>"],
                    "read": ["<HTTP_METHOD>", "<URI>"],
                    "readAll": ["<HTTP_METHOD>", "<URI>"],
                    "update": ["<HTTP_METHOD>", "<URI>"],
                    "delete": ["<HTTP_METHOD>", "<URI>"],
                }
            },
    ...
}
```
The URL will combine in this format: `<HOST>/<BASE_NAME>/<URI>`

If you have a model name 'user'. The default endpoints will look something like this
```
{
    "host": "http://127.0.0.1:8080"
    ...
    "models": {
        "user": {
            "endpoints": {
                "name": "user",
                "actions":{
                    "create": ["POST", "0"],
                    "read": ["GET", "$id"],
                    "readAll": ["GET", ""],
                    "update": ["PUT", "$id"],
                    "delete": ["DELETE", "$id"],
                }
            },
    ...
}
```
And the URL for these five actions will be:
```
Create:     POST    http://127.0.0.1:8080/user/0
Read:       GET     http://127.0.0.1:8080/user/5
Update:     PUT     http://127.0.0.1:8080/user/5
Delete:     DELETE  http://127.0.0.1:8080/user/5
ReadAll:    GET     ttp://127.0.0.1:8080/user
```

** "$id" will be replace by the id currently working on .

** Create and Delete function are not yet implemented.


## To-Dos
* Authentication
* Create and Delete models
* Enhance UI
* Config file edit interface
* And more...