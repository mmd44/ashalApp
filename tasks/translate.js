/* global require, process*/

var fs = require('fs');
var readline = require('readline');
var google = require('googleapis');
var googleAuth = require('google-auth-library');

var baseDir = './ubq/ubq/Resources/'
var spreadSheetId = '1WEf_Y9Fr3ZWGwmmrlLPkkYgVzeMWz2u1R_GtxMyPw64';
var range = 'Sheet1!A2:D'

// If modifying these scopes, delete your previously saved credentials
// at ~/.credentials/sheets.googleapis.com-nodejs-quickstart.json
var SCOPES = ['https://www.googleapis.com/auth/spreadsheets.readonly'];
var TOKEN_DIR = (process.env.HOME || process.env.HOMEPATH ||
    process.env.USERPROFILE) + '/.credentials/';
var TOKEN_PATH = TOKEN_DIR + 'sheets.googleapis.com-nodejs-quickstart.json';

// Load client secret
var client = {
    "installed": {
        "client_id": "176556814394-024hi6hfsphl0u8aakos4699g4p0j9t9.apps.googleusercontent.com",
        "project_id": "webbanking-167509",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://accounts.google.com/o/oauth2/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_secret": "A10_ft8O443__MBTs9CfFpKw",
        "redirect_uris": ["urn:ietf:wg:oauth:2.0:oob", "http://localhost"]
    }
};
authorize(client, generateLocalization);

/**
 * Create an OAuth2 client with the given credentials, and then execute the
 * given callback function.
 *
 * @param {Object} credentials The authorization client credentials.
 * @param {function} callback The callback to call with the authorized client.
 */
function authorize(credentials, callback) {
    var clientSecret = credentials.installed.client_secret;
    var clientId = credentials.installed.client_id;
    var redirectUrl = credentials.installed.redirect_uris[0];
    var auth = new googleAuth();
    var oauth2Client = new auth.OAuth2(clientId, clientSecret, redirectUrl);

    // Check if we have previously stored a token.
    fs.readFile(TOKEN_PATH, function (err, token) {
        if (err) {
            getNewToken(oauth2Client, callback);
        } else {
            oauth2Client.credentials = JSON.parse(token);
            callback(oauth2Client);
        }
    });
}

/**
 * Get and store new token after prompting for user authorization, and then
 * execute the given callback with the authorized OAuth2 client.
 *
 * @param {google.auth.OAuth2} oauth2Client The OAuth2 client to get token for.
 * @param {getEventsCallback} callback The callback to call with the authorized
 *     client.
 */
function getNewToken(oauth2Client, callback) {
    var authUrl = oauth2Client.generateAuthUrl({
        access_type: 'offline',
        scope: SCOPES
    });
    console.log('Authorize this app by visiting this url: ', authUrl);
    var rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });
    rl.question('Enter the code from that page here: ', function (code) {
        rl.close();
        oauth2Client.getToken(code, function (err, token) {
            if (err) {
                console.log('Error while trying to retrieve access token', err);
                return;
            }
            oauth2Client.credentials = token;
            storeToken(token);
            callback(oauth2Client);
        });
    });
}

/**
 * Store token to disk be used in later program executions.
 *
 * @param {Object} token The token to store to disk.
 */
function storeToken(token) {
    try {
        fs.mkdirSync(TOKEN_DIR);
    } catch (err) {
        if (err.code != 'EEXIST') {
            throw err;
        }
    }
    fs.writeFile(TOKEN_PATH, JSON.stringify(token));
    console.log('Token stored to ' + TOKEN_PATH);
}

/**
 * Generate translation files:
 * https://docs.google.com/spreadsheets/d/1nNNHZXmBcK31AHbZRMsuSzjeyea0DoTovCY56RZScaY/edit#gid=511517246
 */
function generateLocalization(auth) {
    var sheets = google.sheets('v4');
    sheets.spreadsheets.values.get({
        auth: auth,
        spreadsheetId: spreadSheetId,
        range: range,
    }, function (err, response) {
        if (err) {
            console.log('The API returned an error: ' + err);
            return;
        }
        var rows = response.values;
        if (rows.length == 0) {
            console.log('No data found.');
        } else {

            var enStrings = {};
            var arStrings = {};
            var frStrings = {};
            for (var i = 0; i < rows.length; i++) {
                var row = rows[i]; // key
                enStrings[row[0]] = row[1]; // en
                arStrings[row[0]] = row[2] || row[1]; // ar
                frStrings[row[0]] = row[3] || row[1]; // fr
            }


            fs.writeFile('../flutter/assets/i18n/en.json', JSON.stringify(enStrings));
            fs.writeFile('../flutter/assets/i18n/ar.json', JSON.stringify(arStrings));
            fs.writeFile('../flutter/assets/i18n/fr.json', JSON.stringify(frStrings));


            console.log('Successfully generated mobile localization files');

                       fs.writeFile('../web/web/assets/i18n/en.json', JSON.stringify(enStrings));
                        fs.writeFile('../web/web/assets/i18n/ar.json', JSON.stringify(arStrings));
                        fs.writeFile('../web/web/assets/i18n/fr.json', JSON.stringify(frStrings));


                        console.log('Successfully generated web localization files');

        }

    });
}