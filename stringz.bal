import ballerina/mime;
import ballerina/io;
import ballerina/log;
import ballerina/regex;

public isolated function searchMatch(string fullString, string searchForStart, string searchForEnd) returns string? {
    string[] frontEnd = regex:split(fullString, searchForStart);
    if frontEnd.length() > 1 {
        string[] backEnd = regex:split(frontEnd[1], searchForEnd);
        if backEnd.length() > 1 {
            return backEnd[0];
        }
    }
    return;
}

public isolated function searchMatchTags(string fullString, string tag) returns string? {
    return searchMatch(fullString, "<" + tag + ">", "</" + tag + ">");
}

public isolated function stringToBase64(string currentString) returns string {
    do {
        string|byte[]|io:ReadableByteChannel|mime:EncodeError current = mime:base64Encode(currentString);
        if current is mime:EncodeError {
            return "";
        } else if current is byte[] || current is io:ReadableByteChannel {
            return "";
        } else {
            return current;
        }
    } on fail var e {
        log:printError({errorMsg: e.message()}.toJsonString());
        return "";
    }
}

public isolated function base64ToString(string base64String) returns string {
    do {
        return <string>check mime:base64Decode(base64String);
    } on fail var e {
        log:printError({errorMsg: e.message()}.toJsonString());
        return "";

    }
}

public isolated function safeIntString(string input, int default = -1) returns int {
    int|error output = int:fromString(input);
    if output is error {
        return -1;
    } else {
        return output;
    }
}

public isolated function pystring(string pythonCmd) returns string {
    return "-c \"import base64;exec(base64.b64decode('" + stringToBase64(pythonCmd) + "').decode())\"";
}
