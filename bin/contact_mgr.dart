import 'dart:async';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:start/start.dart' as start;

import 'package:contactManager/model.dart';
import 'package:contactManager/db.dart';

Repository _repository;

void main(List<String> args)
{
  var parsedArgs = _parseArgs(args);
  var port = int.parse(parsedArgs['port']);
  var numberOfContacts = int.parse(parsedArgs['numContacts']);
  var dbStrategyConfig = parsedArgs['dbStrategy'];
  var dbUri = parsedArgs['dbUri'];

  print("DB Strategy is $dbStrategyConfig");
  _repository = _createRepository(dbStrategyConfig, dbUri);

  _buildContacts(numberOfContacts, _repository).then((contactsCreated) {
    print("Created $contactsCreated Contacts");
    _startServer(port);
  });
}

Repository _createRepository(String dbStrategyConfig, String dbUri) {
  DbStrategy dbStrategy;
  
  switch(dbStrategyConfig) {
    case "postgres": 
      dbStrategy = new PostgresStrategy(dbUri);
      break;
    case "memory":
    default:
      dbStrategy = new MemoryStrategy();
      break;
  }

  var repository = new Repository(dbStrategy);
  return repository;
}

void _startServer(int port) {
  start.start(port: port).then((server) {
    runZoned(() {
      _setupRoutes(server);    
    },
    onError: (error, stackTrace) {
      print("ERROR: $error\n$stackTrace");
    });
  }).then((_) {
    print("Listening on port: $port");
  });
}

void _setupRoutes(start.Server server) {
  server.get("/contact").listen(getAllContacts);  
  server.post("/contact").listen(saveNewContacts); 
  server.delete("/contact").listen(deleteAllContacts);    
  server.get("/contact/:id").listen(getContact);    
}

Future<int> _buildContacts(int numberOfContacts, Repository repository) {
  print("Building DB");
  var contactsCreated = 0;
  return Future.forEach(new List.generate(numberOfContacts, (index) => index), (index) {
      return repository.saveContact(new Contact("Test", "User${index + 1}")).then((_) {
        return ++contactsCreated;
      });
    }).then((_) {
      return contactsCreated;
    });
}
  
ArgResults _parseArgs(List<String> args) {
  var parser = new ArgParser();
  parser.addOption("port", abbr: 'p', help: "Server Port", defaultsTo: "8888");
  parser.addOption("numContacts", abbr: 'n', help: "Number of Contacts to Build in the DB", defaultsTo: "10");
  parser.addOption("dbStrategy", abbr: 'd', help: "Database Strategy", defaultsTo: "memory");
  parser.addOption("dbUri", abbr: 'u', help: "Database URI", defaultsTo: "postgres://postgres:postgres@127.0.0.1:5555/postgres");

  var parsedArgs = parser.parse(args);

  return parsedArgs;
}


Future<Contact> _readContactFromRequest(Stream<List<int>> requestStream) {
  return requestStream.transform(UTF8.decoder).transform(JSON.decoder).first.then((contactMap) {
    var contact = new Contact(contactMap['firstName'], contactMap['lastName']);
    return contact;
  });
}

void getAllContacts(start.Request request) {
  request.response.add("[");
  var needsComma = false;

  _repository.findContacts().listen((contact) {
    var contactAsMap = contact.toMap();
    var contactJson = JSON.encode(contactAsMap);

    if (needsComma) {
      request.response.add(",\n");
    } else {
      needsComma = true;
    }
    request.response.add(contactJson);
  }, onDone: () {
    request.response.add("]");
    request.response.close();
  });
}

void saveNewContacts(start.Request request) {
  _readContactFromRequest(request.input).then((contact) {
    _repository.saveContact(contact).then((savedContact) {
      var savedContactJson = JSON.encode(savedContact.toMap()); 
      request.response.send(savedContactJson);
    })
    .catchError((error, stackTrace) {
      _handleRequestError(request, error, stackTrace);
    });
  });
}

void _handleRequestError(start.Request request, dynamic error, StackTrace stackTrace) {
  request.response.status(500); 
  request.response.send('{"status": "SERVER ERROR"}');
  throw error;
}

void deleteAllContacts(start.Request request) {
  _repository.deleteAllContacts().then((deleteCount) {
    request.response.send(JSON.encode({"contactsDeleted": deleteCount}));
  });
}

void getContact(start.Request request) {
  var contactId = request.params['id'];
  _repository.findContact(contactId).then((contact) {
    var contactJson = JSON.encode(contact.toMap());
    request.response.send(contactJson);
  });
}
