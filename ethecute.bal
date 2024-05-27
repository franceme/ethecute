// https://ballerina.io/learn/language-basics/#define-classes
// Reference := https://github.com/franceme/bal_dlc/blob/master/splunk.bal
import ballerina/file;
import ballerina/io;
import ballerina/os;
import ballerina/time;

type CMD record {|
    string cmd;
    time:Utc addedat;
|};

public type ExeOut record {|
    int exitCode;
    string output;
    string exeStartUTC;
    string exeEndUTC;
    string? success;
    string? failure;
|};

public isolated client class Vessel {

    string executor;
    CMD[] history;
    string comment;
    string filename;

    function init(string executionpath="python3", string filename="bal_temp_file.py", string comment="#") returns error? {
        self.executor = executionpath;
        self.comment = comment;
        self.filename = filename;
    }

    function fileExists(string filePath) returns boolean {
        boolean|error result = file:test(filePath, file:EXISTS);
        return result is error ? false : result;
    }

    public function rmIfExists(string filePath) {
        boolean|error response = file:test(filePath, file:EXISTS);
        if !(response is error) && response {
            error? deleteResponse = file:remove(filePath);
            if deleteResponse is error {
                io:println("Error Removing the file");
            }
        }
    }

    public function exe() returns ExeOut {
        ExeOut output = {
            "exitCode": -1,
            "output": "",
            "exeStartUTC":(),
            "exeEndUTC":(),
            "success": (),
            "failure": ()
        };

        string[] content = [];

        foreach CMD command in self.history {
            content.push("");
            content.push(`{self.comment} {time:utcToString(self.addedat)}`);
            content.push(command.cmd);
            content.push("");
        }

        self.rmIfExists(self.filename);
        io:Error? result = io:fileWriteLines(self.filename, content);


        //https://ballerina.io/spec/os/
        output.exeStart = time:utcToString(time:utcNow());
        os:Process|os:Error process = os:exec({value: self.executor, arguments: [self.filename]});
        output.exeEnd = time:utcToString(time:utcNow());

        if process is error {
            output.output = process.message();
            output.failure = process.message();
        } else {
            byte[]|error success = process.output(io:stdout);
            byte[]|error failure = process.output(io:stderr);
            int|error exitCode = process.waitForExit();

            output.success = success is error ? () : success.toString();
            output.failure = failure is error ? () : failure.toString();
            output.output = output.success ?: output.failure ?: "";
            output.exitCode = exitCode is error ? -1 : exitCode;
        }
        self.rmIfExists(self.filename);

        return output;
    }

    resource isolated function get .() returns ExeOut {
        return self.exe();
    }

    resource isolated function post .(string additionalcmd) returns ExeOut {
        self.history.push(new CMD(
            cmd: additionalcmd,
            addedat: time:utcNow()
        ));
        return self.exe();
    }

}