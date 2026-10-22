// import {environment} from "../environment";
// import http from "../shared/services/http-service.js";


// export const doGetMyConsultationHistoryUrl = environment.baseUrl + '/api/consultations';
// export const doGetPendingConsultationsUrl = environment.baseUrl + '/api/consultations/in-queue';
// export const doAssignConsultationBaseurl = environment.baseUrl + '/api/consultations/assign/'  ;
// export const doCompleteConsultationBaseurl = environment.baseUrl + '/api/consultations/update/' ;

// export const doGetMyConsultationHistory = () => {

//     return http.get(doGetMyConsultationHistoryUrl);

// }
// export const doGetPendingConsultations = () => {
//     return http.get(doGetPendingConsultationsUrl);


// }

// export const doAssignConsultation = (testRequestId) => {


//     let request ={}

//     return http.put(doAssignConsultationBaseurl  + testRequestId, request);


// }
// export const doCompleteConsultation = (testRequestId,consultationResult) => {

//     // {
//     //     "comments": "string",
//     //     "suggestion": "NO_ISSUES"
//     // }




//     return http.put(doCompleteConsultationBaseurl + testRequestId, consultationResult);


// }


import { environment } from "../environment";
import http from "../shared/services/http-service.js";


// ===============================
// CONSULTATION API BASE URL
// ===============================

const consultationBaseUrl = environment.MASTER_HOST_URL + "/api/consultations";


// ===============================
// GET MY CONSULTATION HISTORY
// ===============================

export const doGetMyConsultationHistoryUrl =
    consultationBaseUrl;

export const doGetMyConsultationHistory = () => {
    return http.get(doGetMyConsultationHistoryUrl);
};


// ===============================
// GET PENDING CONSULTATIONS
// ===============================

export const doGetPendingConsultationsUrl =
    consultationBaseUrl + "/in-queue";

export const doGetPendingConsultations = () => {
    return http.get(doGetPendingConsultationsUrl);
};


// ===============================
// ASSIGN CONSULTATION
// ===============================

export const doAssignConsultationBaseurl =
    consultationBaseUrl + "/assign/";

export const doAssignConsultation = (testRequestId) => {

    const request = {};

    return http.put(
        doAssignConsultationBaseurl + testRequestId,
        request
    );
};


// ===============================
// COMPLETE / UPDATE CONSULTATION
// ===============================

export const doCompleteConsultationBaseurl =
    consultationBaseUrl + "/update/";

export const doCompleteConsultation = (
    testRequestId,
    consultationResult
) => {

    return http.put(
        doCompleteConsultationBaseurl + testRequestId,
        consultationResult
    );
};
