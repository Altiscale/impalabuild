impalabuild
==
Repo wrapper for Impala v1.3.1 build for Hadoop 2.4.1 with Hive 0.12.0.
Impala: https://github.com/cloudera/impala/tree/cdh5-1.3_5.0.3

```
git clone -b cdh5-1.3_5.0.3 https://github.com/cloudera/Impala.git
```

HOW-TO
==
Just simply run the build.sh script, this will create a SRPM for mock.
The final artifact will be the impala v1.3.1-cdh5 RPM for Hive 0.12.

Known Issue
==
The current Impala 1.3.1 CDH5.0.3 does not support hadoop 2.2. nor Hive 0.13 due to various reasons.

It links to Hadoop 2.3 libhdfs.so and uses the APIs from Hadoop 2.3. Not backward compatible for Hadoop 2.2

MetaStoreClient API has changed to collec stats so the Front-end code won't work.
Hive 0.13 is supported in Impala 1.5+.

