package com.example.writeboard.been;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.Random;

public class User implements Parcelable {
    String userId;
    String userName;
    String passWord;

    public User() {
    }

    public User( String userName, String passWord) {
        this.userName = userName;
        this.passWord = passWord;
        setUserId();
    }

    protected User(Parcel in) {
        userId = in.readString();
        userName = in.readString();
        passWord = in.readString();
    }

    public static final Creator<User> CREATOR = new Creator<User>() {
        @Override
        public User createFromParcel(Parcel in) {
            return new User(in);
        }

        @Override
        public User[] newArray(int size) {
            return new User[size];
        }
    };

    public  void setUserId(){
        Random random=new Random();
        userId="user";
        for(int i=0;i<12;i++){
            if(i==0){
                userId+=(random.nextInt(9)+1);
            }else{
                userId+=random.nextInt(10);
            }
        }
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public void setPassWord(String passWord) {
        this.passWord = passWord;
    }

    public String getUserId() {
        return userId;
    }

    public String getUserName() {
        return userName;
    }

    public String getPassWord() {
        return passWord;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(userId);
        dest.writeString(userName);
        dest.writeString(passWord);
    }
}
