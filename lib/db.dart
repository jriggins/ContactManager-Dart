library db;

import "dart:async";

import "package:uuid/uuid_server.dart";

import "package:contactManager/model.dart";

abstract class DbStrategy {
  Future<Contact> saveContact(Contact contact);
  Future<Contact> findContact(String contactId);
  Stream<Contact> findContacts();
  Future<Contact> findContactByName(String contactName);
  Future<int> deleteAllContacts();
}

class MemoryStrategy implements DbStrategy {

  List<Contact> contactList = [];
  
  @override
  Future<Contact> saveContact(Contact contact) {
    var newContactId = new Uuid().v4();
    var newContact = new Contact.newContact(newContactId, contact);
    contactList.add(newContact);
    return new Future.value(newContact);
  }
  
  @override
  Future<Contact> findContact(String contactId) {
    var foundContact = contactList.firstWhere((contact) => 
        contact.id == contactId);
    return new Future.value(foundContact);
  }

  @override
  Stream<Contact> findContacts() {
    var stream = new Stream.fromIterable(contactList);
    return stream;
  }
  
  @override
  Future<Contact> findContactByName(String contactName) {
    var foundContact = contactList.firstWhere((contact) => 
        contact.name.toLowerCase().contains(contactName.toLowerCase()));
    return new Future.value(foundContact);
  }


  @override
  Future<int> deleteAllContacts() {
    var contactLength = contactList.length;
    contactList = [];
    return new Future.value(contactLength);
  }
}

class Repository {
  DbStrategy _dbStrategy;

  Repository(DbStrategy dbStrategy) {
    _dbStrategy = dbStrategy;
  }
  
  Future<Contact> saveContact(Contact contact) {
    return _dbStrategy.saveContact(contact);
  }
  
  Future<Contact> findContact(String contactId) {
    return _dbStrategy.findContact(contactId);   
  }
  
  Stream<Contact> findContacts() {
    return _dbStrategy.findContacts();
  }
  
  Future<Contact> findContactByName(String contactName) {
    return _dbStrategy.findContactByName(contactName);
  }
  
  Future<int> deleteAllContacts() {
    return _dbStrategy.deleteAllContacts();
  }
}