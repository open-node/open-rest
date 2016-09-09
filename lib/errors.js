var restify = require('restify')
  , slice   = [].slice
  , util    = require('util');

var ArgumentError = function(error) {
  restify.RestError.call(this, {
    restCode: 'ArgumentError',
    statusCode: 422,
    message: error.errors || error.message,
    constructorOpt: ArgumentError
  });
  return this.name = 'ArgumentError';
};

var NormalError = function(error) {
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

var errors = {

  notFound: function(msg, field) {
    if (msg == null) msg = 'Resource not found.';
    if (!field) return new restify.ResourceNotFoundError(msg);
    return new ArgumentError({
      errors: [{
        message: msg,
        path: field
      }]
    });
  },

  notAllowed: function(msg) {
    if (msg == null) msg = 'Not allowed error.';
    return new restify.ForbiddenError(msg);
  },

  notAuth: function(msg) {
    if (msg == null) msg = 'Not authorized error.';
    return new restify.NotAuthorizedError(msg);
  },

  invalidArgument: function(msg, values) {
    var error = new restify.InvalidArgumentError(msg || 'Invalid argument error.');
    if (values != null) error.body.value = values;
    return error;
  },

  missingParameter: function(msg, missings) {
    var error = new restify.MissingParameterError(msg || 'Missing parameter error.');
    if (missings) error.body.value = missings;
    return error;
  },

  sequelizeIfError: function(error, field) {
    if (!error) return null;
    if (field) {
      error = {
        errors: [{
          message: error.message,
          path: field
        }]
      };
    }
    return new ArgumentError(error);
  },

  ifError: function(error, field) {
    if (!error) return null;
    if (field) return errors.sequelizeIfError(error, field);
    return error;
  },

  normalError: function(msg) {
    var values = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    return new NormalError({
      errors: [{
        message: msg || 'Normal error.',
        values: values
      }]
    });
  },

  error: function(msg) {
    var values = 2 <= arguments.length ? slice.call(arguments, 1) : []
      , error = new Error(msg || 'Unknown error.');
    error.value = values;
    return error;
  }

};

module.exports = errors;
