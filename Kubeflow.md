# Installing Kubeflow
> TODO: create a helm chart for this

## Installation
* Start a fresh cluster
  * Nodes w/ at least 8GB RAM, 2CPU
* Install [kfctl](https://github.com/kubeflow/kfctl/releases/tag/v1.0.1)
* `kfctl apply -V -f https://raw.githubusercontent.com/kubeflow/manifests/v1.0-branch/kfdef/kfctl_k8s_istio.v1.0.1.yaml`
* `kubectl get all -n kubeflow` to watch the deployment


## Set up Ingress
> Note: this is probably the wrong way to do it.

* `reckoner plot util/course.yaml --only nginx-ingress`
* `helm upgrade --install cert-issuer charts/cert-issuer/ --set email="you@example.com"`
* create a username/password for basic auth:
  * `htpasswd -c auth yourname` and choose a password
  * `kubectl create secret generic basic-auth --from-file=auth -n istio-system`
* Edit `kubeflow/ingress.yaml` with your own domain name
* `kubectl apply -f kubeflow/ingress.yaml`
* Find the loadbalancer IP (automatically created in DO)
* Edit DNS settings to point the specified domain to your load balancer

## Run an Example
* go to your domain to see the kubeflow server
  * use the username/password set up in the auth step
* create a new namespace
* click `notebook servers`
* click `new server`
  * choose a name
  * use image `gcr.io/kubeflow-images-public/tensorflow-1.15.2-notebook-cpu:1.0.0`
  * bump up CPU and memory
* click `launch`
* click `connect` when your server is ready
* click `New` -> `Python 3 Notebook`
* paste and run code below


```python
from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets("MNIST_data/", one_hot=True)

import tensorflow as tf

x = tf.placeholder(tf.float32, [None, 784])

W = tf.Variable(tf.zeros([784, 10]))
b = tf.Variable(tf.zeros([10]))

y = tf.nn.softmax(tf.matmul(x, W) + b)

y_ = tf.placeholder(tf.float32, [None, 10])
cross_entropy = tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(y), reduction_indices=[1]))

train_step = tf.train.GradientDescentOptimizer(0.05).minimize(cross_entropy)

sess = tf.InteractiveSession()
tf.global_variables_initializer().run()

for _ in range(1000):
  batch_xs, batch_ys = mnist.train.next_batch(100)
  sess.run(train_step, feed_dict={x: batch_xs, y_: batch_ys})

correct_prediction = tf.equal(tf.argmax(y,1), tf.argmax(y_,1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
print("Accuracy: ", sess.run(accuracy, feed_dict={x: mnist.test.images, y_: mnist.test.labels}))
```

```python
import numpy as np
import matplotlib.pyplot as plt

NUM_TO_SHOW=10

testImages = mnist.test.next_batch(NUM_TO_SHOW)
guesses = sess.run(y, feed_dict={x: testImages[0]})
def guess_to_string(guess):
    return str(np.argmax(guess))
for i in range(NUM_TO_SHOW):
    pixels = (np.array(testImages[0][i], dtype='float')).reshape(28,28)
    guess = guess_to_string(guesses[i])
    label = guess_to_string(testImages[1][i])
    plt.title('Guess is {guess} | Actual is {label}'.format(guess=guess, label=label))
    plt.imshow(pixels, cmap='gray')
    plt.show()
```
