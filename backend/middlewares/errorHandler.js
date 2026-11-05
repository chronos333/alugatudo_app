function errorHandler(err, req, res, next) {
  console.error('[API Error]', err.stack || err.message);

  const statusCode = err.status || err.statusCode || 400;
  res.status(statusCode).json({
    success: false,
    error: {
      message: err.message || 'Ocorreu um erro interno no servidor.'
    }
  });
}

module.exports = errorHandler;

