import {createReducer} from "../config/create-reducer";
import {REHYDRATE} from 'redux-persist';
import {setAuthToken} from "./authDispatcher";

export const LOGIN = "auth/login";
export const LOGOUT = "auth/logout";



const getDefaultRoles =()=>{
    return getApplicableRoles({role:"ANONYMOUS"})
}

export const getApplicableRoles = (user) => {

    const isApproved = user?.status === "APPROVED";

    const roles = user?.roles || [];
    const roleNames = roles.map(role => role.name);

    const isUser = roleNames.includes("USER");
    const isDoctor = roleNames.includes("DOCTOR");
    const isAuthority = roleNames.includes("GOVERNMENT_AUTHORITY");
    const isTester = roleNames.includes("TESTER");

    return {
        isUser,
        isDoctor,
        isAuthority,
        isTester,
        isApproved
    };
};

export const initialState = {
    isLoggedIn:false,
    token:null,
    user:null,
    roles:getDefaultRoles()
}


const loginUser =(state,action)=>{

    let updatedState = {}
    if(action?.payload?.user){
        const roles =getApplicableRoles(action.payload.user)
        updatedState={isLoggedIn:true,token:action.payload.token,user:action.payload.user,roles}
    }
    return { ...state,...updatedState}



};
const logOutUser =(state,action)=>{

    return { ...state,isLoggedIn:false,token:null,user:null,roles:getDefaultRoles()}

};
const rehydrateApp =(state,action)=>{

    if(action?.payload?.auth?.user){
        let {auth} = action.payload;
        let {user,token} = auth
        setAuthToken(token)
        const roles =getApplicableRoles(user)

        return { ...state,isLoggedIn:true,token:token,user:user,roles}
    }else {
        return {...state}
    }


};




const authReducer = createReducer(initialState, {
    [LOGIN]: loginUser,
    [REHYDRATE]:rehydrateApp,
    [LOGOUT]: logOutUser



});


export default authReducer;

