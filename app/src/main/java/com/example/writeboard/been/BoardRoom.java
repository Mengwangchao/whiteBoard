package com.example.writeboard.been;

import android.os.Parcel;
import android.os.Parcelable;

import com.example.writeboard.view.PaletteView;

public class BoardRoom implements Parcelable {

    private String roomCreatorId;
    private double roomId;
    private int roomMode = 1;
    private int currentPage;
    private PaletteView[] PageList;

    public void setRoomCreatorId(String roomCreatorId) {
        this.roomCreatorId = roomCreatorId;
    }

    public void setRoomId(double roomId) {
        this.roomId = roomId;
    }

    public void setRoomMode(int roomMode) {
        this.roomMode = roomMode;
    }

    public void setCurrentPage(int currentPage) {
        this.currentPage = currentPage;
    }

    public void setPageList(PaletteView[] pageList) {
        PageList = pageList;
    }


    protected BoardRoom(Parcel in) {
        roomCreatorId = in.readString();
        roomId = in.readDouble();
        roomMode = in.readInt();
        currentPage = in.readInt();
    }

    public static final Creator<BoardRoom> CREATOR = new Creator<BoardRoom>() {
        @Override
        public BoardRoom createFromParcel(Parcel in) {
            return new BoardRoom(in);
        }

        @Override
        public BoardRoom[] newArray(int size) {
            return new BoardRoom[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
dest.writeString(roomCreatorId);
dest.writeDouble(roomId);
dest.writeInt(roomMode);
dest.writeInt(currentPage);
dest.writeArray(PageList);
    }

}
