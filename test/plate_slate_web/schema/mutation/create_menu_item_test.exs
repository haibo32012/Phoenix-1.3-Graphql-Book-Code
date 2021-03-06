defmodule PlateSlateWeb.Schema.Mutation.CreateMenuItemText do
  use PlateSlateWeb.ConnCase, async: true

  alias PlateSlate.{Repo, Menu}

  import Ecto.Query

  setup do
    Code.load_file("priv/repo/seeds.exs")

    category_id =
      from(t in Menu.Category, where: t.name == "Sandwiches")
      |> Repo.one!
      |> Map.fetch!(:id)
      |> to_string

    IO.puts "category id: #{category_id}"

    {:ok, category_id: category_id}
  end

  @query """
  mutation ($menuItem: MenuItemInput!) {
    createMenuItem(input: $menuItem) {
      errors { key message }
      menuItem {
        name
        description
        price
      }
    }
  }
  """

  test "createMenuItem field create a menuItem", %{category_id: category_id} do
    menu_item = %{
      "name" => "French Dip",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => category_id,
    }

    response = post(build_conn(), "/api", query: @query, variables: %{"menuItem" => menu_item})

    assert json_response(response, 200) == %{
      "data" => %{
        "createMenuItem" => %{
          "errors" => nil,
          "menuItem" => %{
            "name" => menu_item["name"],
            "description" => menu_item["description"],
            "price" => menu_item["price"],
          }
        }
      }
    }
  end

  test "creating a menu item with existing name fails", %{category_id: category_id} do
    menu_item = %{
      "name" => "Rueben",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => category_id
    }

    response = post(build_conn(), "/api", query: @query, variables: %{"menuItem" => menu_item})

    assert json_response(response, 200) == %{
      "data" => %{
        "createMenuItem" => %{
          "errors" => [
            %{"key" => "name", "message" => "has already been taken"}
          ],
          "menuItem" => nil
        }
      },
    }
  end

end
