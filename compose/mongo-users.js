db.createUser({
  user: 'unifiuser',
  pwd: 'hunter2',
    roles: [
    {
      role: 'clusterMonitor',
      db: 'admin',
    },
    {
      role: 'clusterManager',
      db: 'admin',
    },
    {
      role: 'dbAdmin',
      db: 'unifi1',
    },
    {
      role: 'readWrite',
      db: 'unifi1',
    },
    {
      role: 'dbAdmin',
      db: 'unifi1_stat',
    },
    {
      role: 'readWrite',
      db: 'unifi1_stat',
    },
  ],
});
