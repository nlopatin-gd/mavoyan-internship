from fastapi import FastAPI, HTTPException, Depends, Header
from pydantic import BaseModel
from typing import List, Dict, Optional
import uuid
import threading
import time
import uvicorn
import os
from dotenv import load_dotenv

app = FastAPI()

load_dotenv()  

admin_token = os.getenv("ADMIN_TOKEN")

if not admin_token:
    raise RuntimeError("ADMIN_TOKEN is not set in .env file")

pizzas = {
    1: {"name": "Margherita", "price": 8.99},
    2: {"name": "Pepperoni", "price": 9.99},
    3: {"name": "Veggie", "price": 10.99}
}

orders = {}
users = {}

class Pizza(BaseModel):
    name: str
    price: float

class Order(BaseModel):
    user_id: str
    pizza_id: int

class OrderStatus(BaseModel):
    order_id: str
    status: str

class User(BaseModel):
    user_id: str
    address: str

def verify_admin_token(authorization: str = Header(...)):
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header format")
    token = authorization.split(" ")[1]
    if token != admin_token:
        raise HTTPException(status_code=401, detail="Unauthorized: Invalid admin token")

def update_order_statuses():
    while True:
        time.sleep(30)  
        for order_id, order in list(orders.items()):
            if order["status"] == "ordered":
                order["status"] = "ready_to_be_delivered"

threading.Thread(target=update_order_statuses, daemon=True).start()

@app.post("/register")
def register_user(user: User):
    if user.user_id in users:
        raise HTTPException(status_code=400, detail="User already exists")
    users[user.user_id] = {"address": user.address}
    return {"message": "User registered successfully"}

@app.get("/menu", response_model=Dict[int, Pizza])
def get_menu():
    return pizzas

@app.post("/order", response_model=OrderStatus)
def create_order(order: Order):
    if order.pizza_id not in pizzas:
        raise HTTPException(status_code=400, detail="Pizza not found")
    if order.user_id not in users:
        raise HTTPException(status_code=400, detail="User not registered")

    order_id = str(uuid.uuid4())
    orders[order_id] = {
        "user_id": order.user_id,
        "pizza_id": order.pizza_id,
        "status": "ordered"
    }
    return {"order_id": order_id, "status": "ordered"}

@app.get("/order/{order_id}", response_model=OrderStatus)
def check_order_status(order_id: str):
    order = orders.get(order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return {"order_id": order_id, "status": order["status"]}

@app.delete("/order/{order_id}", response_model=OrderStatus)
def cancel_order(order_id: str):
    order = orders.get(order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    if order["status"] == "ready_to_be_delivered":
        raise HTTPException(status_code=400, detail="Order already ready to be delivered")
    del orders[order_id]
    return {"order_id": order_id, "status": "canceled"}

@app.post("/menu", response_model=Pizza)
def add_pizza(pizza: Pizza, token: str = Depends(verify_admin_token)):
    pizza_id = max(pizzas.keys(), default=0) + 1
    pizzas[pizza_id] = pizza.dict()
    return pizza

@app.delete("/menu/{pizza_id}", response_model=Pizza)
def delete_pizza(pizza_id: int, token: str = Depends(verify_admin_token)):
    if pizza_id not in pizzas:
        raise HTTPException(status_code=404, detail="Pizza not found")
    return pizzas.pop(pizza_id)

@app.delete("/order/{order_id}/admin", response_model=OrderStatus)
def admin_cancel_order(order_id: str, token: str = Depends(verify_admin_token)):
    if order_id not in orders:
        raise HTTPException(status_code=404, detail="Order not found")
    del orders[order_id]
    return {"order_id": order_id, "status": "canceled by admin"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)