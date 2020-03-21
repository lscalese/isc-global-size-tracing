## What's new in this version

* Compatibility Iris 2019 (issue ^$["^^/path/to/database/]GLOBAL fixed).  


# Global Size Tracing

Tool to keep track of all globals and databases size.    
A scheduled task's running every day in order to retrieve the new globals and database size and store the value in a table.  
Data are available by rest call.  
This is a backend application, there is no gui web application.  


## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation 

Open terminal and clone/git pull the repo into any local directory

```
$ git clone https://github.com/lscalese/isc-global-size-tracing.git
```

Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```

## How to Run the Application

Open InterSystems IRIS terminal:

```
$ docker exec -it isc-global-size-tracing_iris_1 irissession iris
USER>zn "IRISAPP"
IRISAPP>Set tSc = ##class(Iris.Tools.Monitor.Tasks.UpdateSize).cmTask() 
```

This process retrieve all globals and database size and store the values to the following tables : 

* Iris_Tools_Monitor_Data.DBSize
* Iris.Tools.Monitor.Data.GlobalSize

## Install scheduled task

The scheduled task is installed by defaut by the Installer class.  

Manual install if needed, open an Iris terminal : 
```
Zn "IRISAPP"
Set tSc = ##class(Iris.Tools.Monitor.Tasks.UpdateSize).installTask()
```

## Unit test

Running unit test : 
```
zn "IRISAPP"
Do ##class(Iris.Tools.Monitor.Test.UnitTestUtils).StartUnitTest()
```

## Retrieving data

### Global size

Global size services are available in class : [Iris.Tools.Monitor.Services.GlobalSizeServices](src/cls/Iris/Tools/Monitor/Services/GlobalSizeServices.cls).  
See the class reference documentation for more informations.  

Example for retrieve all globals size of database "IRIS-APP" : 

```
Set database = ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).getDbDirectory("IRISAPP-DATA")
Set result = ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).get(database,"*","Day",$zd($h,3),$zd($h,3))
Do result.%ToJSON()
```

### Database size

Database size services are available in class : [Iris.Tools.Monitor.Services.DBSizeServices](src/cls/Iris/Tools/Monitor/Services/DBSizeServices.cls)  
See the class reference documentation for more informations.  

Example for retrieve databases size : 

```
Set result = ##class(Iris.Tools.Monitor.Services.DBSizeServices).get("*","Day",$zd($h,3),$zd($h,3))
Do result.%ToJSON()
```

### Rest call

A fews services are exposed for rest call.  
See [Iris.Tools.Monitor.Rest.Size class](src/cls/Iris/Tools/Monitor/Rest/Size.cls) class.  
A [Postman collection](postman/Global_Size_Tracing.postman_collection.json) is also available.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.  



## How to start coding
This repository is ready to code in VSCode with ObjectScript plugin.
Install [VSCode](https://code.visualstudio.com/), [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) and [ObjectScript](https://marketplace.visualstudio.com/items?itemName=daimor.vscode-objectscript) plugins and open the folder in VSCode.

Right-click on **docker-compose.yml** file and click Compose Restart

Once docker will finish starting procedure and show:

```
Creating objectscript-contest-template_iris_1 ... done
```

Click on the ObjectScript status bar and select Refresh connection in the menu.
Wait for VSCode to make connection and show something like "localhost:32778[IRISAPP] - Connected"

You can start coding after that. Open **ObjectScript.cls** in VSCode, make changes and save - the class will be compiled by IRIS on 'Save'.

## Happy coding!
