import "package:unittest/unittest.dart";

import "dart:async";

import "package:contactManager/db.dart";
import "package:contactManager/model.dart";

void main() {
  group("Contact Model", () {
    test("Initialize", () {
      var contact = new Contact("Test", "User");
      expect(contact, isNotNull);
      expect(contact.firstName, "Test");
      expect(contact.lastName, "User");
    });

    test("Get Full Name", () {
      var contact = new Contact("Test", "User");
      expect(contact.name, "Test User");
    });
  });
  
  group("Repository", () {
    group("MemoryStrategy", () {
      test("Initialize", () {
        var memoryStrategy = new MemoryStrategy();
        var repository = new Repository(memoryStrategy);
        expect(repository, isNotNull);
      }); 
      
      test("Save Contact", () {
        var contact = new Contact("Test", "User");  
        var memoryStrategy = new MemoryStrategy();
        var repository = new Repository(memoryStrategy);
        
        return repository.saveContact(contact).then((savedContact) {
          expect(savedContact, isNotNull);  
          expect(savedContact.id, matches(r"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}"));  
        })
        .catchError((error, stackTrace) {
          fail("Contact save error should not be thrown"); 
        }, test: (error) => error is! TestFailure);
      });
      
      group("Find Contact", () {
        test("By Contact ID", () {
          var memoryStrategy = new MemoryStrategy();
          var repository = new Repository(memoryStrategy);

          List<Contact> foundContacts;
          return Future.wait([
            repository.saveContact(new Contact("Test", "User1")),
            repository.saveContact(new Contact("Test", "User2")),
            repository.saveContact(new Contact("Test", "User3")),
            repository.saveContact(new Contact("Test", "User4")),
            repository.saveContact(new Contact("Test", "User5"))
          ], eagerError: true).then((List<Contact> results) {
            foundContacts = results;
            return repository.findContact(results[3].id);  
          }).then((contact) {
            expect(contact.id, isNotNull);
            expect(contact.id, foundContacts[3].id);
          });
        });  

        test("All Contacts", () {
          var memoryStrategy = new MemoryStrategy();
          var repository = new Repository(memoryStrategy);

          List<Contact> foundContacts;
          return Future.wait([
            repository.saveContact(new Contact("Test", "User1")),
            repository.saveContact(new Contact("Test", "User2")),
            repository.saveContact(new Contact("Test", "User3")),
            repository.saveContact(new Contact("Test", "User4")),
            repository.saveContact(new Contact("Test", "User5"))
          ], eagerError: true).then((List<Contact> results) {
            foundContacts = results;
            return repository.findContacts();
          }).then((contacts) {
            expect(contacts, isNotNull);
            return contacts.toList();
          }).then((contactsAsList) {
            expect(contactsAsList[2].id, foundContacts[2].id);
          });
        });  

        test("Find Contact by Name", () {
          var memoryStrategy = new MemoryStrategy();
          var repository = new Repository(memoryStrategy);

          List<Contact> foundContacts;
          return Future.wait([
            repository.saveContact(new Contact("Test", "User1")),
            repository.saveContact(new Contact("Test", "User2")),
            repository.saveContact(new Contact("Test", "User3")),
            repository.saveContact(new Contact("Test", "User4")),
            repository.saveContact(new Contact("Test", "User5"))
          ], eagerError: true).then((List<Contact> results) {
            foundContacts = results;
            return repository.findContactByName("est user4");
          }).then((contact) {
            expect(contact, isNotNull);
            expect(contact.id, foundContacts[3].id);
          });
        });  
      });
    });
  });
}

