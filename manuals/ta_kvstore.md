# Techage/Beduino  Key/Value Store

The key/value store simplifies the handling/comparison of strings.

The following example shows the use of the Key/Value Store, here to check the names from the Player Detector:

```c
import "ta_kvstore.c"
import "ta_iom.c"

var s[16];

func init() {
  // Init and fill-up the k/v store
  ta_kv_init();
  ta_kv_add("singleplayer", 1);
  ta_kv_add("Tom", 2);
  ta_kv_add("Betty", 3);
  ta_kv_add("Joe", 4);
}

func loop() {
  var val;

  if(event()) { // Signal from player detector received
    request_data(5, 144, "", s); // Request player name from player detector
    val = ta_kv_get(s); // Read value for the given name in 's'
    if(val == 1) {
      // do A...
    } else if(val == 2) {
      // do B...
    } else if(val == 3) {
      // do C...
    } 
  }
}    
```



Each controller has a key/value store that must be initialized via `ta_kv_init()` and filled via `ta_kv_add` before it can be used.

### ta_kv_init

Initializes the key/value store. Has to be called once at the beginning.

```c
ta_kv_init()
```



### ta_kv_add

Add a new key/value pair to the store.

- *key_str* is the string
- *value* is the value to be stored, which can be read again using the key string

```c
 ta_kv_add(key_str, value) 
```



### ta_kv_get

Read a value from thre store. 

- *key_str* is the string

The function returns 0, if *key_str* is unknown.

```c
ta_kv_get(key_str)
```


