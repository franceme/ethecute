// https://ballerina.io/learn/language-basics/#define-classes
// Reference := https://github.com/franceme/bal_dlc/blob/master/splunk.bal
import ballerina/file;
import ballerina/io;
import ballerina/os;
import ballerina/time;

public type CMD record {|
    string cmd;
    time:Utc addedat;
|};

public type ExeOut record {|
    int exitCode;
    string output;
    string? exeStartUTC;
    string? exeEndUTC;
    string? success;
    string? failure;
|};

public isolated client class Vessel {

    private final string executor;
    private final CMD[] history;
    private final string comment;
    private final string filename;

    public isolated function init(string executionpath="python3", string filename="bal_temp_file.py", string comment="#") returns error? {
        self.history = [];
        self.executor = executionpath;
        self.comment = comment;
        self.filename = filename;
    }

    public isolated function fileExists(string filePath) returns boolean {
        boolean|error result = file:test(filePath, file:EXISTS);
        return result is error ? false : result;
    }


    public isolated function rmIfExists(string filePath) {
        boolean|error response = file:test(filePath, file:EXISTS);
        if !(response is error) && response {
            error? deleteResponse = file:remove(filePath);
            if deleteResponse is error {
                io:println("Error Removing the file");
            }
        }
    }

    public isolated function addCmd(string additionalcmd) {
        lock {
            self.history.push({
                cmd: additionalcmd,
                addedat: time:utcNow()
            });
        }
    }

    private isolated function exe() returns ExeOut {
        ExeOut output = {
            "exitCode": -1,
            "output": "",
            "exeStartUTC":(),
            "exeEndUTC":(),
            "success": (),
            "failure": ()
        };

        lock {
            self.rmIfExists(self.filename);
        }

        lock {
            string[] content = [];

            foreach CMD command in self.history {
                content.push("");
                content.push(self.comment + " " + time:utcToString(command.addedat));
                content.push(command.cmd);
                content.push("");
            }

            io:Error? result = io:fileWriteLines(self.filename, content);
        }

        //https://ballerina.io/spec/os/
        output.exeStartUTC = time:utcToString(time:utcNow());
        os:Process|os:Error process = os:exec({value: self.executor, arguments: [self.filename]});
        output.exeEndUTC = time:utcToString(time:utcNow());

        if process is error {
            output.output = process.message();
            output.failure = process.message();
        } else {
            byte[]|error success = process.output(io:stdout);
            byte[]|error failure = process.output(io:stderr);
            int|error exitCode = process.waitForExit();

            output.success = success is error ? () : (string:fromBytes(success) is error ? () : string:fromBytes(success));
            output.failure = failure is error ? () : (string:fromBytes(failure) is error ? () : string:fromBytes(failure));
            output.output = output.success ?: output.failure ?: "";
            output.exitCode = exitCode is error ? -1 : exitCode;
        }
        lock {
            self.rmIfExists(self.filename);
        }
        return output;
    }

    resource isolated function get .() returns ExeOut {
        return self.exe();
    }

    resource isolated function post .(string additionalcmd) returns ExeOut {
        self.addCmd(additionalcmd);
        return self.exe();
    }

}