module Kernel
  def =~(obj)
    false
  end

  def ===(other)
    `self == other`
  end

  def Object (object)
    Opal.native?(object) ? Native::Object.new(object) : object
  end

  def Array(object)
    return [] unless object

    unless Opal.native?(object)
      return object.to_ary if object.respond_to? :to_ary
      return object.to_a   if object.respond_to? :to_a
    end

    `
      var length = object.length || 0,
          result = new Array(length);

      while (length--) {
        result[length] = object[length];
      }

      return result;
    `
  end

  def at_exit(&block)
    `
      if (block === nil) {
        rb_raise(RubyArgError, 'called without a block');
      }

      rb_end_procs.push(block);

      return block;
    `
  end

  def class
    `rb_class_real(self.$k)`
  end

  def define_singleton_method(&body)
    `
      if (body === nil) {
        rb_raise(RubyLocalJumpError, 'no block given');
      }

      VM.ds(self, name, body);

      return self;
    `
  end

  def equal?(other)
    `self === other`
  end

  def extend(*mods)
    `
      for (var i = 0, length = mods.length; i < length; i++) {
        rb_include_module(rb_singleton_class(self), mods[i]);
      }

      return self;
    `
  end

  def hash
    `return self.$id`
  end

  def inspect
    to_s
  end

  def instance_of?(klass)
    `self.$k === klass`
  end

  def instance_variable_defined?(name)
    `self.hasOwnProperty(name.substr(1));`
  end

  def instance_variable_get(name)
    `
      var ivar = self[name.substr(1)];

      return ivar == undefined ? nil : ivar;
    `
  end

  def instance_variable_set(name, value)
    `self[name.substr(1)] = value`
  end

  def instance_variables
    `
      var result = [];

      for (var name in self) {
        result.push(name);
      }

      return result;
    `
  end

  def is_a?(klass)
    `
      var search = self.$k;

      while (search) {
        if (search === klass) {
          return true;
        }

        search = search.$s;
      }

      return false;
    `
  end

  alias_method :kind_of?, :is_a?

  def lambda(&block)
    block
  end

  def loop(&block)
    return enum_for :loop unless block_given?

    `
      while (true) {
        if ($yielder.call($context, null) === breaker) {
          return breaker.$v;
        }
      }

      return self;
    `
  end

  def nil?
    false
  end

  def object_id
    `self.$id || (self.$id = rb_hash_yield++)`
  end

  def print(*strs)
    $stdout.print *strs
  end

  def proc(&block)
    block
  end

  def puts(*strs)
    $stdout.puts *strs
  end

  def raise(exception, string = undefined)
    `
      var msg, exc;

      if (typeof(exception) === 'string') {
        exc = #{`RubyRuntimeError`.new `exception`};
      }
      else if (#{exception.is_a? `RubyException`}) {
        exc = exception;
      }
      else {
        if (string !== undefined) {
          msg = string;
        }

        exc = #{`exception`.new `msg`};
      }

      throw exc;
    `
  end

  def rand(max = undefined)
    `max === undefined ? Math.random() : Math.floor(Math.random() * max)`
  end

  def require(path)
    `
      var resolved = rb_find_lib(path);

      if (!resolved) {
        rb_raise(RubyLoadError, 'no such file to load -- ' + path);
      }

      if (LOADER_CACHE[resolved]) {
        return false;
      }

      LOADER_CACHE[resolved] = true;
      LOADER_FACTORIES[resolved](rb_top_self, resolved);

      return true;
    `
  end

  def respond_to?(name)
    `
      var meth = self[mid_to_jsid(name)];

      if (meth && !meth.method_missing) {
        return true;
      }

      return false;
    `
  end

  def singleton_class
    `rb_singleton_class(self)`
  end

  def tap(&block)
    `
      if (block === nil) {
        rb_raise(RubyLocalJumpError, 'no block given');
      }

      if ($yielder.call($context, null, self) === breaker) {
        return breaker.$v;
      }

      return self;
    `
  end

  def to_s
    `rb_inspect_object(self)`
  end
end