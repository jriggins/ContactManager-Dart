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

  DbStrategy dbStrategy = new MemoryStrategy();
  _repository = new Repository(dbStrategy);

  _buildContacts(numberOfContacts, _repository).then((_) {
    start.start(port: port).then((server) {
      server.get("/contact").listen(getAllContacts);  
      server.post("/contact").listen(saveNewContacts); 
      server.delete("/contact").listen(deleteAllContacts);    
      server.get("/contact/:id").listen(getContact);    
    });
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
    });
  });
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
