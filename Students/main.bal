import ballerina/io;
import ballerina/http;
import ballerina/log;

endpoint http:Client studentData{
    url: " http://localhost:9090"
};

function main(string... args) {
    http:Request req = new;
    int operation = 0;
    while ( operation != 5) {
        // print options menu to choose from
        io:println("Select operation.");
        io:println("1. Add student");
        io:println("2. View all students");
        io:println("3. Find a student");
        io:println("4. Delete a student");
        io:println("5. Exit");
        io:println("6. Make a mock error");
        io:println();

        // read user's choice
        string choice = io:readln("Enter choice 1 - 5: ");
        if (!isInteger(choice)){
            io:println("Choice must be of a number");
            io:println();
            continue;
        }

            operation = check <int>choice;

        // Program runs until the user inputs 5 to terminate the process
        if (operation == 5) {
            break;
        }



        //user chooses to add a student
        if(operation == 1) {

            //get student name, age mobile number, address
            var name = io:readln("Enter Student name: ");
            var age = io:readln("Enter Student age: ");
            var mobile = io:readln("Enter mobile number: ");
           var add = io:readln("Enter Student address: ");

            //create the request as json message
         json jsonMsg = {"name":name, "age":check <int>age,"mobNo":check <int>mobile,"address":add};


         req.setJsonPayload(jsonMsg);

        //send the request to students service and get the response from it
        var resp= studentData->post("/records/addStudent",req);
        match resp {
            http:Response response => {
                var msg = response.getJsonPayload();            //obtaining the result from the response received
                match msg {
                  json jsonPL => {
                        string message = "Status: " + jsonPL["Status"] .toString() + "/n Added Student Id :- " + jsonPL["id"].toString();   //Extracting data from json received and displaying
                        io:println(message);
                    }

                  error err => {
                      log:printError(err.message, err = err);                       //Print error
                  }
                }
            }

            error err => {
                log:printError(err.message, err = err);                            //Print error
            }
        }


        }
        //user chooses to list down all the students
        else if(operation == 2) {

            //sending a request to list down all students and get the response from it
            var requ= studentData->post("/records/viewAll",null);

            match requ {
                http:Response response => {
                    var msg = response.getJsonPayload();        //obtaining the result from the response received
                    match msg {
                        json jsonPL => {
                            string message;
                            if (lengthof  jsonPL >= 1) {            //validate to check if records are available
                                int i;
                                io:println();
                                // Loop through the received json array and display data
                                while (i < lengthof jsonPL) {

                                    message = "Student Name: " + jsonPL[i]["name"] .toString()+", " + " Student Age: " +
                                        jsonPL[i]["age"] .toString();
                                    io:println(message);
                                    i++;
                                }
                                io:println();
                            }
                            else {

                                // Notify user if no records are available
                                message = "Student record is empty";
                                io:println(message);
                            }


                        }

                        error err => {
                            log:printError(err.message, err = err);            //Print any error caused
                        }
                    }
                }

                error err => {
                    log:printError(err.message, err = err);                    //Print any error caused
                }
            }
        
        }

        // User chooses to find a student by Id
        else if(operation == 3) {

            // Get student id
            var id = io:readln("Enter student id: ");

            // Request made to find the student with the given id and get the response from it
            var requ= studentData->get("/records/view/"+check <int>id);

             match requ {
            http:Response response => {
                var msg = response.getJsonPayload();            //obtaining the result from the response received
                match msg {
                  json jsonPL => {
                      string message;
                      if (lengthof  jsonPL >= 1) {              // Validate to check if student with given ID exist in the system
                          message = "Student Name: " + jsonPL[0]["name"] .toString() + " Student Age: " + jsonPL[0][
                              "age"] .toString();
                      }
                      else {
                          message = "Student with the given ID doesn't exist";
                      }

                      io:println();
                      io:println(message);
                      io:println();
                    }

                  error err => {
                      log:printError(err.message, err = err);           //Print any error caused
                  }
                }
            }

            error err => {
                log:printError(err.message, err = err);                 // Print any error caused
            }
        }

        
        }

        // User chooses to delete a student by Id
        else if(operation == 4) {

            // Get student id
            var id = io:readln("Enter student id: ");

            // Request made to find the student with the given id and get the response from it
            var requ = studentData->get("/records/deleteStu/" + check <int>id);

            match requ {
                http:Response response => {
                    var msg = response.getJsonPayload();            //obtaining the result from the response received
                    match msg {
                        json jsonPL => {
                            string message;

                                message = jsonPL["Status"].toString();


                            io:println();
                            io:println(message);
                            io:println();
                        }

                        error err => {
                            log:printError(err.message, err = err);           //Print any error caused
                        }
                    }
                }

                error er => {
                    io:println(er.message);
                }
            }
        }

        else if(operation==6) {
            var requ = studentData->get("/records/testError");
            match requ {
                http:Response response => {
                    var msg = response.getTextPayload();            //obtaining the result from the response received
                    match msg {
                        string message => {



                            io:println();
                            io:println(message);
                            io:println();
                        }

                        error err => {
                            log:printError(err.message, err = err);           //Print any error caused
                        }
                    }
                }

                error er => {
                    io:println(er.message);
                }
            }
        }
        else {
            io:println("Invalid choice");
        }   
    }
}

function isInteger(string input) returns boolean {
    string regEx = "\\d+";
    boolean isInt = check input.matches(regEx);
    return isInt;
}
