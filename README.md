# kube-watch

[Kubernetes](http://kubernetes.io) Watch API for node.

## [Installation](#installation)

```bash
$ npm i kube-watch
```

## [Quick start](#quick-start)

```javascript
import KubeWatch from 'kube-watch';

const pods = new KubeWatch('pods', {
  url: 'http://kube-api-server'   // Kubernetes API URL
});

pods
  .on('added', event => {
    console.log('Pod %s added to namespace %s with IP address %s',
      event.metadata.name, event.metadata.namespace, event.status.podIP);
  })
  .on('modified', event => {
    // do something...
  })
  .on('deleted', event => {
    // ..do something else..
  })
  .on('error', err => {
    console.error('Error %d: %s', err.code, err.message);
  });
```

## [Watching resources](#watching-resources)

By default, [kube-watch](https://github.com/subk/kube-watch) will first request Kubernetes API to fetch the
last `resourceVersion` for requested resource.  
See [documentation](https://github.com/kubernetes/kubernetes/blob/master/docs/devel/api-conventions.md#concurrency-control-and-consistency) for more details.  
If you want to specify `resourceVersion` manually, see [Query Parameters](#query-parameters) section.

`new KubeWatch(resource, options)` -> `EventEmitter`

### [Supported API & Resources](#supported-api)
See [Kubernetes API documentation](http://kubernetes.io/docs/api/) for more details.

**API v1**
- `namespaces`
- `endpoints`
- `events`
- `limitranges`
- `persistentvolumeclaims`
- `persistentvolumes`
- `pods`
- `podtemplates`
- `replicationcontrollers`
- `resourcequotas`
- `secrets`
- `serviceaccounts`
- `service`

**API v1beta1**
- `horizontalpodautoscalers`
- `ingresses`
- `jobs`

API version will be automatically selected depending on requested resource.

### [by namespace](#watch-by-namespace)

Watch all services in namespace `public` :  
```javascript
const services = new KubeWatch('services', {
  url: 'http://kube-api-server',
  namespace: 'public'
});
```

### [by name](#watch-by-name)

Only watch service named `www` in namespace `public` :  
```javascript
const services = new KubeWatch('services', {
  url: 'http://kube-api-server',
  namespace: 'public',
  name: 'www'
});
```

## [Filtering events](#filtering-events)

You can filter which events will be emitted using `events` option.  
By default, [kube-watch](https://github.com/subk/kube-watch) will emit all k8s events: `added`, `modified`, `deleted`.

```javascript
const namespaces = new KubeWatch('namespaces', {
  url: 'http://kube-api-server',
  events: [ 'added' ]   // watcher will only emit 'added' event
});
```

## [Query parameters](#query-parameters)

These extra query parameters are supported as option :
- `labelSelector`
- `fieldSelector`
- `resourceVersion`
- `timeoutSeconds`

```javascript
const services = new KubeWatch('services', {
  url: 'http://kube-api-server',
  labelSelector: 'public-http',
  fieldSelector: 'event.status.podIP',
  resourceVersion: '6587423'
});
```

See [documentation](http://kubernetes.io/docs/api-reference/v1/operations/) for more details about these options.

## [Request options](request-options)

HTTP requests are performed using [request](https://www.npmjs.com/package/request) package.  
Pass custom options using `request` property.  

```javascript
const services = new KubeWatch('services', {
  url: 'http://kube-api-server',
  request: {
    timeout: 30000    // change HTTP request timeout
  }
});
```

### [HTTP Auth](#http-auth)

See request's [http authentication](https://www.npmjs.com/package/request#http-authentication)

```javascript
const services = new KubeWatch('services', {
  url: 'http://kube-api-server',
  request: {
    auth: {
      user: 'foobar'
      pass: 'el8'
    }
  }
});
```

### [TLS/SSL support](#tls-ssl-support)
See request's [TLS/SSL support](https://www.npmjs.com/package/request#tlsssl-protocol).

```javascript
const services = new KubeWatch('services', {
  url: 'https://kube-api-server/api/v1',
  request: {
    cert: fs.readFileSync(certFile),
    key: fs.readFileSync(keyFile),
    passphrase: 'password',
    ca: fs.readFileSync(caFile)
  }
});
```

## [Tests](#tests)

Run test.js in watch mode :  
```bash
$ env KUBE_API_SERVER=http://kube-api-server \
    npm run test:watch
```

Single run :  
```bash
$ env KUBE_API_SERVER=http://kube-api-server \
    npm run test:single
```

Run tests using [minikube](https://github.com/kubernetes/minikube) to simulate workload.  
See [test/run-test.sh](test/run-test.sh).
```bash
$ npm test
```

## [TODO](#todo)
- Improve test suites by simulating workload
