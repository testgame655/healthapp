const docSvc = process.env.REACT_APP_DOCSVC_HOST || '';
const regSvc = process.env.REACT_APP_REGSVC_HOST || '';
const masterSvc = process.env.REACT_APP_MASTERSVC_HOST || '';

// Use relative URLs for production (nginx proxy) or absolute URLs for development
const useRelativeUrls = process.env.NODE_ENV === 'production';

export const environment = {
  // =========================
  // MASTER SERVICE - 8081
  // =========================
  MASTER_HOST_URL: useRelativeUrls ? '/api' : `http://${masterSvc || 'localhost'}:8081`,

  LOGIN_URL: useRelativeUrls ? '/api/auth/login' : `http://${masterSvc || 'localhost'}:8081/auth/login`,

  // =========================
  // REGISTER SERVICE - 8082
  // =========================
  REGISTER_BASE_URL: useRelativeUrls ? '/register' : `http://${regSvc || 'localhost'}:8082`,

  REGISTER_URL: useRelativeUrls ? '/register/auth/register' : `http://${regSvc || 'localhost'}:8082/auth/register`,

  DOCTOR_REGISTER_URL: useRelativeUrls ? '/register/auth/doctor/register' : `http://${regSvc || 'localhost'}:8082/auth/doctor/register`,

  TESTER_REGISTER_URL: useRelativeUrls ? '/register/auth/tester/register' : `http://${regSvc || 'localhost'}:8082/auth/tester/register`,

  // =========================
  // DOCUMENT SERVICE - 8083
  // =========================
  DOCUMENT_BASE_URL: useRelativeUrls ? '/document' : `http://${docSvc || 'localhost'}:8083`,

  DOCUMENT_UPLOAD_URL: useRelativeUrls ? '/document/documents/upload' : `http://${docSvc || 'localhost'}:8083/documents/upload`,

  DOCUMENT_DOWNLOAD_URL: useRelativeUrls ? '/document/documents/download' : `http://${docSvc || 'localhost'}:8083/documents/download`,
};