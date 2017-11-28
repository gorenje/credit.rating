function encrypt_data(data, key, callback) {
  var keyObj = KEYUTIL.getKey(key);
  var jwk = KEYUTIL.getJWKFromKey(keyObj);

  var cryptographer = new Jose.WebCryptographer();
  var rsa_key = Jose.Utils.importRsaPublicKey(jwk, "RSA-OAEP");
  cryptographer.setContentEncryptionAlgorithm("A256CBC-HS512");
  var encrypter = new JoseJWE.Encrypter(cryptographer, rsa_key);

  encrypter.encrypt(data).then(callback).catch(function(err){
    console.error(err);
  });
}
