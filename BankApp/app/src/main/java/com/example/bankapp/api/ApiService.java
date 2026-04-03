package com.example.bankapp.api;

import com.example.bankapp.models.*;
import retrofit2.Call;
import retrofit2.http.*;

public interface ApiService {

    @POST("api/register")
    Call<User> register(@Body RegisterRequest request);

    @POST("api/login")
    Call<User> login(@Body LoginRequest loginRequest);

    @GET("api/account/{id}")
    Call<User> getAccount(@Path("id") int userId);

    @POST("api/account/transfer")
    Call<User> makeTransfer(@Body TransferRequest request);

    @PUT("api/account/update")
    Call<User> updateAccount(@Body User user);

    @POST("api/reset-password")
    Call<User> resetPassword(@Body ResetRequest request);
}