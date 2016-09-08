var ArgumentError, NormalError, errors, restify, util,
  slice = [].slice;

restify = require('restify');
util = require('util');

ArgumentError = function(error) {
  restify.RestError.call(this, {
    restCode: 'ArgumentError',
    statusCode: 422,
    message: error.errors || error.message,
    constructorOpt: ArgumentError
  });
  return this.name = 'ArgumentError';
};

NormalError = function(error) {
  restify.RestError.call(this, {
    restCode: 'NormalError',
    statusCode: 500,
    message: error.errors,
    constructorOpt: NormalError
  });
  return this.name = 'NormalError';
};

util.inherits(ArgumentError, restify.RestError);

util.inherits(NormalError, restify.RestError);

module.exports = errors = {
  notFound: function(msg, field) {
    var error;
    if (msg == null) {
      msg = 'Resource not found.';
    }
    if (!field) {
      return new restify.ResourceNotFoundError(msg);
    }
    error = {
      errors: [
        {
          message: msg,
          path: field
        }
      ]
    };
    return new ArgumentError(error);
  },
  notAllowed: function(msg) {
    if (msg == null) {
      msg = 'Not allowed error.';
    }
    return new restify.ForbiddenError(msg);
  },
  notAuth: function(msg) {
    if (msg == null) {
      msg = 'Not authorized error.';
    }
    return new restify.NotAuthorizedError(msg);
  },
  invalidArgument: function(msg, values) {
    var error;
    if (msg == null) {
      msg = 'Invalid argument error.';
    }
    error = new restify.InvalidArgumentError(msg);
    if (values && values.length) {
      error.body.value = values;
    }
    return error;
  },
  missingParameter: function(msg, missings) {
    if (msg == null) {
      msg = 'Missing parameter error.';
    }
    return new restify.MissingParameterError(msg, missings);
  },
  sequelizeIfError: function(error, field) {
    if (!error) {
      return null;
    }
    if (field) {
      error = {
        errors: [
          {
            message: error.message,
            path: field
          }
        ]
      };
    }
    return new ArgumentError(error);
  },
  ifError: function(error, field) {
    if (!error) {
      return null;
    }
    if (field) {
      return errors.sequelizeIfError(error, field);
    }
    return error;
  },
  normalError: function() {
    var msg, values;
    msg = arguments[0], values = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    return new NormalError({
      errors: [
        {
          message: msg,
          values: values
        }
      ]
    });
  },
  error: function() {
    var error, msg, values;
    msg = arguments[0], values = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    error = new Error(msg);
    error.value = values;
    return error;
  }
};
