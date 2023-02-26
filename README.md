


## About MySQL Replication

MySQL replication is a setup where a database server, called the writer or source, is copied to one or more other servers, known as readers or replicas, using binary logs. 

Replication can be configured to copy either the whole database or specific tables. 
By default, replication is asynchronous and one-way, but other synchronization types, such as semi-synchronous and synchronous, may be available through plugins or special configurations.

There are two types of replication setups: chained and circular.

**Chained replication** is a type of MySQL replication setup where there is a chain of database servers. In a chained replication setup, a writer database, also known as the source, is replicated to a reader database, which then serves as a source to another reader database and so on. This is useful when you have a large number of regions to replicate data to, and you want to minimize replication lag.


For example, the replication chain could be 

> Source/Writer 1 --> Reader Replica 1 --> Reader Replica 2

**Circular replication** is a type of replication in which changes made on any node of a cluster are replicated to all other nodes in the cluster. In other words, each node acts as both a writer and a reader at the same time, and changes are propagated in a circular fashion throughout the cluster. This type of replication is often used in distributed databases where high availability and data consistency are critical.This is useful when you have a distributed database cluster where high availability and data consistency are critical.

# AWS Global Aurora MySQL Replication

Amazon Aurora Global Database allows you to set up replication between multiple Aurora clusters in different regions. 
You can set up replication in a circular or chained manner depending on your requirements. 
However, note that once you have set up replication in a certain way, you cannot change the replication topology. 
Therefore, it is important to choose the right replication topology for your needs before setting up replication.

