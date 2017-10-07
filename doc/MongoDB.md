# MongoDB

## useful commands

**connect to mongoDB pod**:
`kubectl exec -it \<pod name\> /bin/bash`

**connect to mongodb**:
`mongo`

**show dbs**:
`show dbs`

**switch dbs**:
`use kafkaconnect`

**show collections**:
`show collections`

**drop collection**:
`db.kafkatopic.drop()`

**number of records in collection**:
`db.kafkatopic.count()`

**get latest recrods**:
`db.kafkatopic.find().sort({_id:-1})`
