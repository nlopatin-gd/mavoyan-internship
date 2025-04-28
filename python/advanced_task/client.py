import argparse
import requests

SERVER_URL = "http://127.0.0.1:8000"

def get_menu():
    res = requests.get(f"{SERVER_URL}/menu")
    for pid, pizza in res.json().items():
        print(f"{pid}: {pizza['name']} - ${pizza['price']}")

def register_user(user_id, address):
    res = requests.post(f"{SERVER_URL}/register", json={"user_id": user_id, "address": address})
    print(res.json())

def create_order(user_id, pizza_id):
    res = requests.post(f"{SERVER_URL}/order", json={"user_id": user_id, "pizza_id": pizza_id})
    print(res.json())

def check_order(order_id):
    res = requests.get(f"{SERVER_URL}/order/{order_id}")
    print(res.json())

def cancel_order(order_id):
    res = requests.delete(f"{SERVER_URL}/order/{order_id}")
    print(res.json())

def admin_add_pizza(token, name, price):
    headers = {"Authorization": f"Bearer {token}"}
    res = requests.post(f"{SERVER_URL}/menu", headers=headers, json={"name": name, "price": price})
    print(res.json())

def admin_delete_pizza(token, pizza_id):
    headers = {"Authorization": f"Bearer {token}"}
    res = requests.delete(f"{SERVER_URL}/menu/{pizza_id}", headers=headers)
    print(res.json())

def admin_cancel_order(token, order_id):
    headers = {"Authorization": f"Bearer {token}"}
    res = requests.delete(f"{SERVER_URL}/order/{order_id}/admin", headers=headers)
    print(res.json())

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--get-menu', action='store_true')
    p.add_argument('--register', nargs=2, metavar=('USER_ID', 'ADDRESS'))
    p.add_argument('--create-order', nargs=2, metavar=('USER_ID', 'PIZZA_ID'))
    p.add_argument('--check-order', metavar='ORDER_ID')
    p.add_argument('--cancel-order', metavar='ORDER_ID')

    p.add_argument('--admin-token')
    p.add_argument('--admin-add-pizza', nargs=2, metavar=('NAME', 'PRICE'))
    p.add_argument('--admin-delete-pizza', metavar='PIZZA_ID', type=int)
    p.add_argument('--admin-cancel-order', metavar='ORDER_ID')

    args = p.parse_args()

    if args.get_menu:
        get_menu()
    elif args.register:
        register_user(args.register[0], args.register[1])
    elif args.create_order:
        create_order(args.create_order[0], int(args.create_order[1]))
    elif args.check_order:
        check_order(args.check_order)
    elif args.cancel_order:
        cancel_order(args.cancel_order)

    if args.admin_token:
        if args.admin_add_pizza:
            admin_add_pizza(args.admin_token, args.admin_add_pizza[0], float(args.admin_add_pizza[1]))
        elif args.admin_delete_pizza:
            admin_delete_pizza(args.admin_token, args.admin_delete_pizza)
        elif args.admin_cancel_order:
            admin_cancel_order(args.admin_token, args.admin_cancel_order)

if __name__ == "__main__":
    main()
