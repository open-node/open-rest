const restify = require('restify');

const util = require('util');

function ArgumentError(error) {
  restify.RestError.call(this, {
    restCode: 'ArgumentError',
    statusCode: 422,
    message: error.errors || error.message,
    constructorOpt: ArgumentError,
  });
  this.name = 'ArgumentError';
}

function NormalError(error) {
  restify.RestError.call(this, {
    restCode: 'NormalError',
    statusCode: 500,
    message: error.errors,
    constructorOpt: NormalError,
  });
  this.name = 'NormalError';
}

util.inherits(ArgumentError, restify.RestError);
util.inherits(NormalError, restify.RestError);

const errors = {
  notFound(_msg, field) {
    const msg = _msg || 'Resource not found.';
    if (!field) return new restify.ResourceNotFoundError(msg);
    return new ArgumentError({
      errors: [{
        message: msg,
        path: field,
      }],
    });
  },

  notAllowed(msg) {
    return new restify.ForbiddenError(msg || 'Not allowed error.');
  },

  notAuth(msg) {
    return new restify.NotAuthorizedError(msg || 'Not authorized error.');
  },

  invalidArgument(msg, values) {
    const error = new restify.InvalidArgumentError(msg || 'Invalid argument error.');
    if (values) error.body.value = values;
    return error;
  },

  missingParameter(msg, missings) {
    const error = new restify.MissingParameterError(msg || 'Missing parameter error.');
    if (missings) error.body.value = missings;
    return error;
  },

  sequelizeIfError(error, field) {
    if (!error) return null;
    if (field) {
      return new ArgumentError({
        errors: [{
          message: error.message,
          path: field,
        }],
      });
    }
    return new ArgumentError(error);
  },

  ifError(error, field) {
    if (!error) return null;
    if (field) return errors.sequelizeIfError(error, field);
    return error;
  },

  normalError(msg, ...values) {
    return new NormalError({
      errors: [{
        message: msg || 'Normal error.',
        values,
      }],
    });
  },

  error(msg, ...values) {
    const error = new Error(msg || 'Unknown error.');
    error.value = values;
    return error;
  },
};

module.exports = errors;
