require 'test_helper'

module Models
  class OvirtTest < ActiveSupport::TestCase
    setup do
      User.current = users :admin
    end

    test "#new_volume should respect preallocate flag" do
      ovirt = Foreman::Model::Ovirt.new
      volume = ovirt.new_volume(:preallocate => '1')
      assert_equal 'false', volume.sparse
      assert_equal 'raw', volume.format

      volume = ovirt.new_volume(:preallocate => '0')
      assert_equal 'true', volume.sparse

      volume = ovirt.new_volume
      assert_equal 'true', volume.sparse
    end

    test "accepts multiple certificates" do
      ovirt = Foreman::Model::Ovirt.new

      cert1 = "-----BEGIN CERTIFICATE-----\r\n" +
              "MIIFdDCCA1ygAwIBAgIJAM5Uqykb3EAtMA0GCSqGSIb3DQEBCwUAME8xCzAJBgNV\r\n" +
              "BAYTAklMMREwDwYDVQQIDAhUZWwgQXZpdjEUMBIGA1UECgwLVGhlIEZvcmVtYW4x\r\n" +
              "FzAVBgNVBAMMDnRoZWZvcmVtYW4ub3JnMB4XDTE4MDMyNDEyMzYyOFoXDTI4MDMy\r\n" +
              "MTEyMzYyOFowTzELMAkGA1UEBhMCSUwxETAPBgNVBAgMCFRlbCBBdml2MRQwEgYD\r\n" +
              "VQQKDAtUaGUgRm9yZW1hbjEXMBUGA1UEAwwOdGhlZm9yZW1hbi5vcmcwggIiMA0G\r\n" +
              "CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDF04/s4h+BgHPG1HDZ/sDlYq925pkc\r\n" +
              "RTVAfnE2EXDAmZ6W4Q9ueDY65MHe3ZWO5Dg72kNSP2sK9kRI7Dk5CAFOgyw1rH8t\r\n" +
              "Hd1+0xp/lv6e4SvSYghxIL68vFe0ftKkm1usqejBM5ZTgKr7JCI+XSIN36F65Kde\r\n" +
              "c+vxwBnayuhP04r9/aaE/709SXML4eRVYW8I3qFy9FPtUOm+bY8U2PIv5fHayqbG\r\n" +
              "cL/4t3+MCtMhHJsLzdBXya+1P5t+HcKjUNlmwoUF961YAktVuEFloGd0RMRlqF3/\r\n" +
              "itU3QNlXgA5QBIciE5VPr/PiqgMC3zgd5avjF4OribZ+N9AATLiQMW78il5wSfcc\r\n" +
              "kQjU9ChOLrzku455vQ8KE4bc0qvpCWGfUah6MvL9JB+TQkRl/8kxl0b9ZinIvJDH\r\n" +
              "ynVMb4cB/TDEjrjOfzn9mWLH0ZJqjmc2bER/G12WQxOaYLxdVwRStD3Yh6PtiFWu\r\n" +
              "sXOk19UOTVkeuvGFVtvzLfEwQ1lDEo7+VBQz8FG/HBu2Hpq3IwCFrHuicikwjQJk\r\n" +
              "nfturgD0rBOKEc1qWNZRCvovYOLL6ihvv5Orujsx5ZCHOAtnVNxkvIlFt2RS45LF\r\n" +
              "MtPJyhAc6SjitllfUEirxprsbmeSZqrIfzcGaEhgOSnyik1WMv6bYiqPfBg8Fzjh\r\n" +
              "vOCbtiDNPmvgOwIDAQABo1MwUTAdBgNVHQ4EFgQUtkAgQopsTtG9zSG3MgW2IxHD\r\n" +
              "MDwwHwYDVR0jBBgwFoAUtkAgQopsTtG9zSG3MgW2IxHDMDwwDwYDVR0TAQH/BAUw\r\n" +
              "AwEB/zANBgkqhkiG9w0BAQsFAAOCAgEAJq7iN+ZroRBweNhvUobxs75bLIV6tNn1\r\n" +
              "MdNHDRA+hezwf+gxHZhFyaAHfTpst2/9leK5Qe5Zd6gZLr3E5/8ppQuRod72H39B\r\n" +
              "vxMlG5zxDss0WMo3vZeKZbTY6QhXi/lY2IZ6OGV4feSvCsYxn27GTjjrRUSLFeHH\r\n" +
              "JVemCwCDMavaE3+OIY4v2P4FcG+MjUvfOB9ahI24TWL7YgrsNVmJjCILq+EeUj0t\r\n" +
              "Gde1SXVyLkqt7PoxHRJAE0BCEMJSnjxaVB329acJgeehBUxjj4CCPqtDxtbz9HEH\r\n" +
              "mOKfNdaKpFor+DUeEKUWVGnr9U9xOaC+Ws+oX7MIEUCDM7p2ob4JwcjnFs1jZgHh\r\n" +
              "Hwig+i7doTlc701PvKWO96fuNHK3B3/jTb1fVvSZ49O/RvY1VWODdUdxWmXGHNh3\r\n" +
              "LoR8tSPEb46lC2DXGaIQumqQt8PnBG+vL1qkQa1SGTV7dJ8TTbxbv0S+sS+igkk9\r\n" +
              "zsIEK8Ea3Ep935cXximz0faAAKHSA+It+xHLAyDtqy2KaAEBgGsBuuWlUfK6TaP3\r\n" +
              "Gwdjct3y4yYUO45lUsUfHqX8vk/4ttW5zYeDiW+HArJz+9VUXNbEdury4kGuHgBj\r\n" +
              "xHD4Bsul65+hHZ9QywKU26F1A6TLkYpQ2rk/Dx9LGICM4m4IlHjWJPFsQdtkyOor\r\n" +
              "osxMtcaZZ1E=\r\n" +
              "-----END CERTIFICATE-----"

      cert2 = "-----BEGIN CERTIFICATE-----\r\n" +
              "MIIFdDCCA1ygAwIBAgIJAMJiz/f2HDayMA0GCSqGSIb3DQEBCwUAME8xCzAJBgNV\r\n" +
              "BAYTAklMMREwDwYDVQQIDAhUZWwgQXZpdjEUMBIGA1UECgwLVGhlIEZvcmVtYW4x\r\n" +
              "FzAVBgNVBAMMDnRoZWZvcmVtYW4ub3JnMB4XDTE4MDMyNDEyNDQxNFoXDTI4MDMy\r\n" +
              "MTEyNDQxNFowTzELMAkGA1UEBhMCSUwxETAPBgNVBAgMCFRlbCBBdml2MRQwEgYD\r\n" +
              "VQQKDAtUaGUgRm9yZW1hbjEXMBUGA1UEAwwOdGhlZm9yZW1hbi5vcmcwggIiMA0G\r\n" +
              "CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQClTtLvHCkP/DB2oYSb7lhh4yswr3we\r\n" +
              "5AknEtM+MEgPRm8ou/iF4UT/u+IfCi0n2M/wUGceIpwuB5mKY29sAWP0IO+UBCmn\r\n" +
              "SIdo8sK7jNmWhgcR4LG9MrX7pOQWFTUc583LSCWNF7V2Nhy2ZCqp5bzATEd207+L\r\n" +
              "4LHCrn1kwdc22ltnR6CY1wWno2OrkVZOJFSGnLEwa8HhMxyBnGygZXt9JObDixp8\r\n" +
              "r69heKpOLn8/QEIwq0FgAb4nxBsnT9igzd0L8a5UuvDQ7SmmOp7iYwJg5TNFtCm8\r\n" +
              "u8fvXx6T+hLfyNFAHJuJ9xlRM5I7qQGSIK9a9xYqANXMpfcEz7p7JbT1AKQHDzJC\r\n" +
              "ncoq/NNFXgJJIcMMxAFUsKrm75ElB0ph6fSaYMxUv2yCBxpZquLJCbavdH5avRDw\r\n" +
              "JXWYzWjEAPG9YEFvF5LI7OhBrN5atrWxltsi3vfADRfiCMFTdgLMwPFI42EjIEK/\r\n" +
              "DEMm4alWVJMRD8coWcsKJ0xxAku/84jWstV7P8+Kfip76XsAkUNbr46pIGIwjw++\r\n" +
              "J+g77ERBugMyW30Te+CAuzVnVy01N+0dNsR2mV9hlRFk9HPohdTgWX9tr+/Px22n\r\n" +
              "yRIXhPLls7Kl4q8J/05wNIbf6oDY2rYjroqJkI/xZdowanxBUWb6zV/1FfHHlAeO\r\n" +
              "IT0l9LUfCdmgdQIDAQABo1MwUTAdBgNVHQ4EFgQUn3QR1z8ZICejC+7OLI6nBUxU\r\n" +
              "0ngwHwYDVR0jBBgwFoAUn3QR1z8ZICejC+7OLI6nBUxU0ngwDwYDVR0TAQH/BAUw\r\n" +
              "AwEB/zANBgkqhkiG9w0BAQsFAAOCAgEAUHqOREvTlPylNxHs+QG8hu+HbwsjY/g+\r\n" +
              "VF4YBzB78tagaCw9McD1S9qvWWFNjeVRtFbKE+OyZdIkte2Yu6UWlQ5A5fHU4ADD\r\n" +
              "CxCsThwiQaywJOZwVV8ZM6JOKtbf1Epa8kPegu1R/858aW1P/6VuPsTX3ZX8Qyon\r\n" +
              "Fyh1GOmZ+uou/jGnaWSchHX1KHryK1UMA9Z3SbpdJQFILs04QyEXaWO/nPcbdd1h\r\n" +
              "Ceshcd/88CDYoxhcJoi6wpjQRvyDOP4txEJw6SgsTXU8vPLDeISqXzr2znSPdL9k\r\n" +
              "K8g7KJqr7KuhGuDk6dKQp0rL4FSFf8SNH3j7UvNa66/kd1N/ejtbwGmKti8uuQZ5\r\n" +
              "z96knnC6SH0fIgQyXk9KVfHBTqPtHAxnBAOXvPRWlDObRNK8SobyEnAQTE8COGT/\r\n" +
              "+9AuMVbmyEyTMRvY7znv1C7EhjEEOOlpr24on12RpqTJSbTFOppYeABu0rpKM9i7\r\n" +
              "anZnga8BSVy4YbUsMpGdHZ5xhJq8ip9AFjcFvAN0qJFMozlGx6MkgHlmhcLGMPks\r\n" +
              "wKFSycux0qh49d/9TQ0KOiooK/sjS2dbz5bj6Z//6MPmSvRlwPhDhRDaT7D8u7cU\r\n" +
              "svKQIHrQJve7KJxXUuPTh3zawRXdDGmdm7D3CbDOqpAIAnR+/rKXnPzQYBMCvCDG\r\n" +
              "2lSBFSVrAlo=\r\n" +
              "-----END CERTIFICATE-----"

      store = ovirt.send(:ca_cert_store, cert1 + "\r\n" + cert2)
      assert store.verify(OpenSSL::X509::Certificate.new(cert1))
      assert store.verify(OpenSSL::X509::Certificate.new(cert2))
    end
  end
end
