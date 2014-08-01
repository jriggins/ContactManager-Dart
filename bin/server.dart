import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'package:contactManager/db.dart';
import 'package:contactManager/model.dart';

void main(List<String> args)
{
  var parsedArgs = _parseArgs(args);
  var port = int.parse(parsedArgs['port']);
  var numberOfContacts = int.parse(parsedArgs['numContacts']);

  DbStrategy dbStrategy = new MemoryStrategy();
  Repository repository = new Repository(dbStrategy);

  _buildContacts(numberOfContacts, repository).then((_) {
    var server = new Server(port, repository);
    server.start();
  });

}

Future _buildContacts(int numberOfContacts, Repository repository) {
  print("Building DB");
  return Future.wait(new List.generate(numberOfContacts, (index) {
      return repository.saveContact(new Contact("Test", "User${index + 1}"));
    }), 
    eagerError: true).then((_) {
      print("Built DB with $numberOfContacts");
    });
}
  
ArgResults _parseArgs(List<String> args) {
  var parser = new ArgParser();
  parser.addOption("port", abbr: 'p', help: "Server Port", defaultsTo: "8888");
  parser.addOption("numContacts", abbr: 'n', help: "Number of Contacts to Build in the DB", defaultsTo: "10");

  var parsedArgs = parser.parse(args);

  return parsedArgs;
}

class Server {
  int _port;
  Repository _repository;

  Server(int port, Repository repository)
  {
    _port = port;
    _repository = repository;
  }

  void start() {
    var ip = InternetAddress.ANY_IP_V4;
    HttpServer.bind(ip, _port).then((server) {
      print("Listening on ${ip.host}:$_port");
      return server.listen((request) {
        route(request);
      });
    });
  }
  
  Future route(HttpRequest request) {
    var route = "${request.method} ${request.uri.path}";
    print("Route: $route");
  
    switch(route) {
      case "GET /contact/":
        handleGetAllContacts(request);
        break;
    }
  }
  
  Future handleGetAllContacts(HttpRequest request) {
    Future result = new Future.value();

    request.response.write("[");
    var needsComma = false;
    _repository.findContacts().listen((contact) {
      var m = { "firstName": contact.firstName };
      var contactJson = JSON.encode(m);

      if (needsComma) {
        request.response.writeln(", ");
      } else {
        needsComma = true;
      }
      request.response.write(contactJson);
    }, onDone: () {
      request.response.write("]");
      result = request.response.close();
    });
    
    return result;
  }
}
