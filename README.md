<h2>Restructuring Phoenix contexts</h2>

Leaving this branch here for explanation, thought process of the project structure.


Phoenix contexts

I've been trying to follow Programming Phoenix exemple. 
Having a module for the changeset and validation for a struct makes
it very concise. However, all these data need basic CRUD operations. Contexts as portrayed in the book

</br>
<h3>Problems</h3>

  
- Multiple functions with similar name: 
  - Chat.delete_server/1, Chat.delete_chatroom/1, Chat.delete_message/1...
- Multiple level of abstraction inside a module:
  - Accounts.get_user/1, Accounts.authenticate_user/2, Accounts.is_admin?/1
- Dividing a module is hard.
  - Server, Chatroom, Message and Participant all feel like they should be in the same Chat context

 
The Chat context becomes confusing because of the noise of basic CRUD functions.
Dividing Chat context in multiple contexts doesn't seem to make sense.
    

However most information about Phoenix projects seem to be structured that way.

<h4>This blog post seems to share my concerns:
http://devonestes.herokuapp.com/a-proposal-for-context-rules
</h4>
<h6>Instead of having a single folder for every schema and module names such as Webchat.administration.Users.User, Webchat.Chat.Chatrooms.Chatroom etc...</h6>
</br>
<h6>
  I propose to create a models folder for every context such as:
  
    - Webchat.administration.Models.User
    - Webchat.administration.Models.Admin
    - Webchat.Chat.Models.Chatroom
    - Webchat.Chat.Models.Server
  

</br>
<h3>Goals:</h3>

  - Good level of abstraction inside a module
  - Simpler modules
  - Clearer dependencies
  - Make future changes easier
  - Better modules naming


</br>
<h4>I will set myself some rules:</h4>

For each structure 3 levels of abstraction:
  - Schema(struct) and validation(changesets) 
  - Secondary context for database operation of the data
  - Main context for Higher level abstraction 

Always alias the whole module. (Will helping when renaming modules)
Never alias multiple modules in one line. (Will help when dividing a module)

Never use Repo outside of Secondary contexts

Allowed to use changesets directly for validation.
  - Otherwise all changesets functions would be copied for no reasons 
  
</br>
<h4>Exemple with users</h4> 


</br>

--------------------Modules changes

Webchat.Accounts.User => Webchat.Administration.Models.User


Webchat.Administration.Users = created


Webchat.Accounts => Webchat.Administration

--------------------Modules changes

</br>

-----------------------------a secondary context function

Users module contains basic CRUD operation with User struct

ex:

Webchat.Accounts.list_users() => Webchat.Administration.Users.list()

-----------------------------a secondary context function


</br>

-----------------------------higher level abstraction 

Accounts context is changed to Administration.

Basic functions are removed.

Administration only has 2 functions.

</br>
Ex:

Webchat.Accounts.is_admin?(%User{id: user_id}) => Webchat.Administration.is_admin?(%User{})

-----------------------------higher level abstraction 

</br>

Why put is_admin?(%User{}) in the main context instead of Admins secondary context?
  - We remove the need for the Admins context to know about the User struct
  - Implementation of is_admin?() could change, while Secondary contexts operations are unlikely to change
  - The operation uses a User but searches the Admin table, so would it be an Admins or a Users function?
  
<h5>Let's make it simple and call it inside Administration for now</h5>


authenticate_user(email, given_pass) seems to fit more in the new Administration module than the old Accounts module.

<h6>Administration context has a lot less noise, it's function are more focused and they fit more with the module's name.</h6>
