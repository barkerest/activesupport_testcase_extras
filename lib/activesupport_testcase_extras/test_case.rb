require 'active_support'

module ActivesupportTestcaseExtras
  ##
  # Adds some extra assertions and methods for use in tests.
  module TestCase

    ##
    # Tests a specific field for presence validation.
    #
    # model::
    #     This must respond to _attribute_ and _attribute=_ as well as _valid?_ and _errors_.
    #
    # attribute::
    #     This must provide the name of a valid attribute in the model.
    #
    # message::
    #     This is optional, but if provided it will be postfixed with the failure reason.
    #
    # regex::
    #     This is the regex to match against the error message to ensure that the failure is for the correct reason.
    #
    def assert_required(model, attribute, message = nil, regex = /can't be blank/i)
      original_value = model.send(attribute)
      assert model.valid?, 'Model should be valid to start.'
      is_string = original_value.is_a?(::String)
      setter = :"#{attribute}="
      model.send setter, nil
      assert_not model.valid?, message ? (message + ': (nil)') : "Should not allow #{attribute} to be set to nil."
      assert model.errors[attribute].to_s =~ regex, message ? (message + ': (error message)') : 'Did not fail for expected reason.'
      if is_string
        model.send setter, ''
        assert_not model.valid?, message ? (message + ": ('')") : "Should not allow #{attribute} to be set to empty string."
        assert model.errors[attribute].to_s =~ regex, message ? (message + ': (error message)') : 'Did not fail for expected reason.'
        model.send setter, '   '
        assert_not model.valid?, message ? (message + ": ('   ')") : "Should not allow #{attribute} to be set to blank string."
        assert model.errors[attribute].to_s =~ regex, message ? (message + ': (error message)') : 'Did not fail for expected reason.'
      end
      model.send setter, original_value
      assert model.valid?, message ? (message + ": !(#{original_value.inspect})") : "Should allow #{attribute} to be set back to '#{original_value.inspect}'."
    end

    ##
    # Tests a specific field for maximum length restriction.
    #
    # model::
    #     This must respond to _attribute_ and _attribute=_ as well as _valid?_ and _errors_.
    #
    # attribute::
    #     This must provide the name of a valid attribute in the model.
    #
    # max_length::
    #     This is the maximum valid length for the field.
    #
    # message::
    #     This is optional, but if provided it will be postfixed with the failure reason.
    #
    # regex::
    #     This is the regex to match against the error message to ensure that the failure is for the correct reason.
    #
    # options::
    #     This is a list of options for the validation.
    #     Currently :start_with and :end_with are recognized.
    #     Use :start_with to specify a prefix for the tested string.
    #     Use :end_with to specify a postfix for the tested string.
    #     This would be most useful when you value has to follow a format (eg - email address :end_with => '@example.com')
    #
    def assert_max_length(model, attribute, max_length, message = nil, regex = /is too long/i, options = {})
      original_value = model.send(attribute)
      assert model.valid?, 'Model should be valid to start.'
      setter = :"#{attribute}="

      if message.is_a?(::Hash)
        options = message.merge(options || {})
        message = nil
      end

      if regex.is_a?(::Hash)
        options = regex.merge(options || {})
        regex = /is too long/i
      end

      pre = options[:start_with].to_s
      post = options[:end_with].to_s
      len = max_length - pre.length - post.length

      # try with maximum valid length.
      value = pre + ('a' * len) + post
      model.send setter, value
      assert model.valid?, message ? (message + ": !(#{value.length})") : "Should allow a string of #{value.length} characters."

      # try with one extra character.
      value = pre + ('a' * (len + 1)) + post
      model.send setter, value
      assert_not model.valid?, message ? (message + ": (#{value.length})") : "Should not allow a string of #{value.length} characters."
      assert model.errors[attribute].to_s =~ regex, message ? (message + ': (error message)') : 'Did not fail for expected reason.'

      model.send setter, original_value
      assert model.valid?, message ? (message + ": !(#{original_value.inspect})") : "Should allow #{attribute} to be set back to '#{original_value.inspect}'."
    end

    ##
    # Tests a specific field for maximum length restriction.
    #
    # model::
    #     This must respond to _attribute_ and _attribute=_ as well as _valid?_ and _errors_.
    #
    # attribute::
    #     This must provide the name of a valid attribute in the model.
    #
    # min_length::
    #     This is the minimum valid length for the field.
    #
    # message::
    #     This is optional, but if provided it will be postfixed with the failure reason.
    #
    # regex::
    #     This is the regex to match against the error message to ensure that the failure is for the correct reason.
    #
    # options::
    #     This is a list of options for the validation.
    #     Currently :start_with and :end_with are recognized.
    #     Use :start_with to specify a prefix for the tested string.
    #     Use :end_with to specify a postfix for the tested string.
    #     This would be most useful when you value has to follow a format (eg - email address :end_with => '@example.com')
    #
    def assert_min_length(model, attribute, min_length, message = nil, regex = /is too short/i, options = {})
      original_value = model.send(attribute)
      assert model.valid?, 'Model should be valid to start.'
      setter = :"#{attribute}="

      if message.is_a?(::Hash)
        options = message.merge(options || {})
        message = nil
      end

      if regex.is_a?(::Hash)
        options = regex.merge(options || {})
        regex = /is too short/i
      end

      pre = options[:start_with].to_s
      post = options[:end_with].to_s
      len = min_length - pre.length - post.length

      # try with minimum valid length.
      value = pre + ('a' * len) + post
      model.send setter, value
      assert model.valid?, message ? (message + ": !(#{value.length})") : "Should allow a string of #{value.length} characters."

      # try with one extra character.
      value = pre + ('a' * (len - 1)) + post
      model.send setter, value
      assert_not model.valid?, message ? (message + ": (#{value.length})") : "Should not allow a string of #{value.length} characters."
      assert model.errors[attribute].to_s =~ regex, message ? (message + ': (error message)') : 'Did not fail for expected reason.'

      model.send setter, original_value
      assert model.valid?, message ? (message + ": !(#{original_value.inspect})") : "Should allow #{attribute} to be set back to '#{original_value.inspect}'."
    end

    ##
    # Tests a specific field for uniqueness.
    #
    # model::
    #     This must respond to _attribute_ and _attribute=_ as well as _valid?_, _errors_, and _save!_.
    #     The model will be saved to perform uniqueness testing.
    #
    # attribute::
    #     This must provide the name of a valid attribute in the model.
    #
    # case_sensitive::
    #     This determines if changing case should change validation.
    #
    # message::
    #     This is optional, but if provided it will be postfixed with the failure reason.
    #
    # regex::
    #     This is the regex to match against the error message to ensure that the failure is for the correct reason.
    #
    #
    # alternate_scopes::
    #     This is also optional.  If provided the keys of the hash will be used to
    #     set additional attributes on the model.  When these attributes are changed to the alternate
    #     values, the model should once again be valid.
    #     The alternative scopes are processed one at a time and the original values are restored
    #     before moving onto the next scope.
    #     A special key :unique_fields, allows you to provide values for other unique fields in the model so they
    #     don't affect testing.  If the value of :unique_fields is not a hash, then it is put back into the
    #     alternate_scopes hash for testing.
    #
    def assert_uniqueness(model, attribute, case_sensitive = false, message = nil, regex = /has already been taken/i, alternate_scopes = {})
      setter = :"#{attribute}="
      original_value = model.send(attribute)

      assert model.valid?, 'Model should be valid to start.'

      if case_sensitive.is_a?(::Hash)
        alternate_scopes = case_sensitive.merge(alternate_scopes || {})
        case_sensitive = false
      end
      if message.is_a?(::Hash)
        alternate_scopes = message.merge(alternate_scopes || {})
        message = nil
      end
      if regex.is_a?(::Hash)
        alternate_scopes = regex.merge(alternate_scopes || {})
        regex = /has already been taken/i
      end

      model.save!
      copy = model.dup

      other_unique_fields = alternate_scopes.delete(:unique_fields)
      if other_unique_fields
        if other_unique_fields.is_a?(::Hash)
          other_unique_fields.each do |attr,val|
            setter = :"#{attr}="
            copy.send setter, val
          end
        else
          alternate_scopes[:unique_fields] = other_unique_fields
        end
      end

      assert_not copy.valid?, message ? (message + ": (#{copy.send(attribute).inspect})") : "Duplicate model with #{attribute}=#{copy.send(attribute).inspect} should not be valid."
      assert copy.errors[attribute].to_s =~ regex, message ? (message + ': (error message)') : "Did not fail for expected reason"
      if original_value.is_a?(::String)
        unless case_sensitive
          copy.send(setter, original_value.upcase)
          assert_not copy.valid?, message ? (message + ": (#{copy.send(attribute).inspect})") : "Duplicate model with #{attribute}=#{copy.send(attribute).inspect} should not be valid."
          assert copy.errors[attribute].to_s =~ regex, message ? (message + ': (error message)') : "Did not fail for expected reason"
          copy.send(setter, original_value.downcase)
          assert_not copy.valid?, message ? (message + ": (#{copy.send(attribute).inspect})") : "Duplicate model with #{attribute}=#{copy.send(attribute).inspect} should not be valid."
          assert copy.errors[attribute].to_s =~ regex, message ? (message + ': (error message)') : "Did not fail for expected reason"
        end
      end

      unless alternate_scopes.blank?
        copy.send(setter, original_value)
        assert_not copy.valid?, message ? (message + ": (#{copy.send(attribute).inspect})") : "Duplicate model with #{attribute}=#{copy.send(attribute).inspect} should not be valid."
        assert copy.errors[attribute].to_s =~ regex, message ? (message + ': (error message)') : "Did not fail for expected reason"
        alternate_scopes.each do |k,v|
          kset = :"#{k}="
          vorig = copy.send(k)
          copy.send(kset, v)
          assert_equal v, copy.send(k), message ? (message + ": (failed to set #{k})") : "Failed to set #{k}=#{v.inspect}."
          assert copy.valid?, message ? (message + ": !#{k}(#{v})") : "Duplicate model with #{k}=#{v.inspect} should be valid with #{attribute}=#{copy.send(attribute).inspect}."
          copy.send(kset, vorig)
          assert_equal vorig, copy.send(k), message ? (message + ": (failed to reset #{k})") : "Failed to reset #{k}=#{v.inspect}."
          assert_not copy.valid?, message ? (message + ": (#{copy.send(attribute).inspect})") : "Duplicate model with #{attribute}=#{copy.send(attribute).inspect} should not be valid."
          assert copy.errors[attribute].to_s =~ regex, message ? (message + ': (error message)') : "Did not fail for expected reason"
        end
      end
    end

    ##
    # Tests a specific field for email verification.
    #
    # model::
    #     This must respond to _attribute_ and _attribute=_ as well as _valid?_ and _errors_.
    #
    # attribute::
    #     This must provide the name of a valid attribute in the model.
    #
    # message::
    #     This is optional, but if provided it will be postfixed with the failure reason.
    #
    # regex::
    #     This is the regex to match against the error message to ensure that the failure is for the correct reason.
    #
    def assert_email_validation(model, attribute, message = nil, regex = /is not a valid email address/i)
      assert model.valid?, 'Model should be valid to start.'
      setter = :"#{attribute}="
      orig = model.send attribute

      valid = %w(
        user@example.com
        USER@foo.COM
        A_US-ER@foo.bar.org
        first.last@foo.jp
        alice+bob@bax.cn
      )

      invalid = %w(
        user@example,com
        user_at_foo.org
        user@example.
        user@example.com.
        foo@bar_baz.com
        foo@bar+baz.com
        @example.com
        user@
        user
        user@..com
        user@example..com
        user@.example.com
        user@@example.com
        user@www@example.com
      )

      valid.each do |addr|
        model.send setter, addr
        assert model.valid?, message ? (message + ': (rejected valid address)') : "Should have accepted #{addr.inspect}."
      end

      invalid.each do |addr|
        model.send setter, addr
        assert_not model.valid?, message ? (message + ': (accepted invalid address)') : "Should have rejected #{addr.inspect}."
        assert model.errors[attribute].to_s =~ regex, message ? (message + ': (error message)') : 'Did not fail for expected reason.'
      end

      model.send setter, orig
      assert model.valid?, message ? (message + ': (rejected original value)') : "Should have accepted original value of #{orig.inspect}."

    end


    ##
    # Tests a specific field for IP address verification.
    #
    # model::
    #     This must respond to _attribute_ and _attribute=_ as well as _valid?_ and _errors_.
    #
    # attribute::
    #     This must provide the name of a valid attribute in the model.
    #
    # mask::
    #     This can be one of :allow_mask, :require_mask, or :deny_mask.  The default is :allow_mask.
    #
    # message::
    #     This is optional, but if provided it will be postfixed with the failure reason.
    #
    # regex::
    #     This is the regex to match against the error message to ensure that the failure is for the correct reason.
    #     The default value is nil to test for the various default messages.
    #
    def assert_ip_validation(model, attribute, mask = :allow_mask, message = nil, regex = nil)
      assert model.valid?, 'Model should be valid to start.'
      setter = :"#{attribute}="
      orig = model.send attribute

      valid = %w(
          0.0.0.0
          1.2.3.4
          10.20.30.40
          255.255.255.255
          10:20::30:40
          ::1
          1:2:3:4:5:6:7:8
          A:B:C:D:E:F::
      )

      invalid = %w(
          localhost
          100.200.300.400
          12345::abcde
          1.2.3.4.5
          1.2.3
          0
          1:2:3:4:5:6:7:8:9:0
          a:b:c:d:e:f:g:h
      )

      valid.each do |addr|
        if mask == :require_mask
          if addr.index(':')
            addr += '/128'
          else
            addr += '/32'
          end
        end
        model.send setter, addr
        assert model.valid?, message ? (message + ': (rejected valid address)') : "Should have accepted #{addr.inspect}."
      end

      r = regex ? regex : /is not a valid ip address/i
      invalid.each do |addr|
        if mask == :require_mask
          if addr.index(':')
            addr += '/128'
          else
            addr += '/32'
          end
        end
        model.send setter, addr
        assert_not model.valid?, message ? (message + ': (accepted invalid address)') : "Should have rejected #{addr.inspect}."
        assert model.errors[attribute].to_s =~ r, message ? (message + ': (error message)') : 'Did not fail for expected reason.'
      end

      if mask == :allow_mask || mask == :require_mask
        address = '127.0.0.0/8'
        model.send setter, address
        assert model.valid?, message ? (message + ': (rejected masked address)') : "Should have accepted #{address.inspect}."
      end

      if mask == :allow_mask || mask == :deny_mask
        address = '127.0.0.1'
        model.send setter, address
        assert model.valid?, message ? (message + ': (rejected unmasked address)') : "Should have accepted #{address.inspect}."
      end

      if mask == :require_mask
        r = regex ? regex : /must contain a mask/i
        address = '127.0.0.1'
        model.send setter, address
        assert_not model.valid?, message ? (message + ': (accepted unmasked address)') : "Should have rejected #{address.inspect} for no mask."
        assert model.errors[attribute].to_s =~ r, message ? (message + ': (error message)') : 'Did not fail for expected reason.'
      end

      if mask == :deny_mask
        r = regex ? regex : /must not contain a mask/i
        address = '127.0.0.0/8'
        model.send setter, address
        assert_not model.valid? message ? (message + ': (accepted masked address)') : "Should have rejected #{address.inspect} for mask."
        assert model.errors[attribute].to_s =~ r, message ? (message + ': (error message)') : 'Did not fail for expected reason.'
      end

      model.send setter, orig
      assert model.valid?, message ? (message + ': (rejected original value)') : "Should have accepted original value of #{orig.inspect}."
    end

    ##
    # Tests a specific field for safe name verification.
    #
    # model::
    #     This must respond to _attribute_ and _attribute=_ as well as _valid?_ and _errors_.
    #
    # attribute::
    #     This must provide the name of a valid attribute in the model.
    #
    # length::
    #     The length of the string to test.  Must be greater than 2.  Default is 6.
    #
    # message::
    #     This is optional, but if provided it will be postfixed with the failure reason.
    #
    # regex::
    #     This is the regex to match against the error message to ensure that the failure is for the correct reason.
    #     The default value is nil to test for the various default messages.
    #
    def assert_safe_name_validation(model, attribute, length = 6, message = nil, regex = nil)
      assert model.valid?, 'Model should be valid to start.'
      setter = :"#{attribute}="
      orig = model.send attribute

      assert length > 2, message ? (message + ': (field is too short to test)') : 'Requires a field length greater than 2 to perform tests.'

      # valid tests.
      mid_length = length - 2
      mid = ''    # _z_z_z_z_z_
      while mid.length < mid_length
        if mid.length + 1 < mid_length
          mid += '_z'
        else
          mid += '_'
        end
      end

      [
          'a' * length,
          'a' + ('1' * (length - 1)),
          'a' + mid + 'a',
          'a' + mid + '1'
      ].each do |val|
        model.send setter, val
        assert model.valid?, message ? (message + ': (rejected valid string)') : "Should have accepted #{val.inspect}."
        val.upcase!
        model.send setter, val
        assert model.valid?, message ? (message + ': (rejected valid string)') : "Should have accepted #{val.inspect}."
      end

      # invalid tests.
      {
          '_' + ('a' * (length - 1)) => /must start with a letter/i,
          '1' + ('a' * (length - 1)) => /must start with a letter/i,
          ('a' * (length - 1)) + '_' => /must not end with an underscore/i,
          ('a' * (length - 2)) + '-' + 'a' => /must contain only letters, numbers, and underscore/i,
          ('a' * (length - 2)) + '#' + 'a' => /must contain only letters, numbers, and underscore/i,
          ('a' * (length - 2)) + ' ' + 'a' => /must contain only letters, numbers, and underscore/i
      }.each do |val, reg|
        r = regex ? regex : reg
        model.send setter, val
        assert_not model.valid?, message ? (message + ': (accepted invalid string)') : "Should have rejected #{val.inspect}."
        assert model.errors[attribute].to_s =~ r, message ? (message + ': (error message)') : "Did not fail for expected reason on #{val.inspect}."
      end

      model.send setter, orig
      assert model.valid?, message ? (message + ': (rejected original value)') : "Should have accepted original value of #{orig.inspect}."
    end

  end
end

ActiveSupport::TestCase.include ActivesupportTestcaseExtras::TestCase
